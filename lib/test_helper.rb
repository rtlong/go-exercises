require 'pathname'
require 'yaml'
require 'subprocess'
require 'ansi/code'

TEST_CASES_FILE = Pathname.new('test_cases.yml')

class ScriptRunner
  def initialize(path)
    @source_path = Pathname.new(path)
  end

  def name
    @source_path.basename
  end

  def run(input, args)
    args = Array(args).map(&:to_s)
    command = [executable_path.expand_path.to_s, *args]
    process = Subprocess.popen(command,
                               stdout: Subprocess::PIPE,
                               stderr: Subprocess::PIPE,
                               stdin: input.nil? ? nil : Subprocess::PIPE)
    stdout, stderr = process.communicate(input)
    return stdout, stderr, process.wait
  end

  def executable_path
    unless @source_path.executable?
      raise NotImplementedError, "The source file #{@source_path.to_s} isn't executable!"
    end
    @source_path
  end

  def prepare
    executable_path
    return true
  end
end

class RubyRunner < ScriptRunner
end

class GoRunner < ScriptRunner
  def executable_path
    return @executable_path if defined?(@executable_path)
    output = @source_path.sub_ext('.o')
    compile(output)
    @executable_path = output
  end

  def compile(target)
    puts ANSI.yellow { "Compiling... #{@source_path} -> #{target}" }
    Subprocess.check_call(['go', 'build', '-o', target.to_s, @source_path.to_s])
  end
end

class Tests
  def initialize(runnables:)
    @runnables = runnables
  end

  def prepare
    return if @prepared

    exit 0 unless test_cases.any?
    test_cases.each do |test|
      test['exit'] ||= 0
    end

    runnables.delete_if do |r|
      begin
        report_errors { r.prepare }
        false
      rescue
        true
      end
    end
    @prepared = true
  end

  def report_errors(&block)
    block.call
  rescue => ex
    puts ANSI.red { "\nError: #{ex.to_s}\n  #{ex.backtrace.join("\n  ")}" }
    raise
  end

  def run
    prepare
    runnables.each do |runnable|
      puts ANSI.blue { runnable.name }
      success = true
      begin
        test_cases.each do |test|
          success &= report_errors { run_one(runnable, test) }
        end
        print "\n"
        unless success
          puts "FAIL"
        end
      rescue
        next
      end
    end
  end

  def run_one(runnable, test)
    stdout, stderr, status = runnable.run(*test.values_at('input', 'args'))

    actual = {
      'out' => stdout,
      'err' => stderr,
      'exit' => status.exitstatus
    }

    if assert_equals(test, actual)
      print ANSI.green { "✓" }
      return true
    else
      print "\n"
      puts ANSI.red { "✗ - expected #{test} but saw #{actual}" }
      return false
    end
  end

  def assert_equals(expected, actual)
    expected = expected.dup.delete_if { |k, _| !%w[out err exit].include?(k) }
    expected.all? do |k, v|
      case v
      when Integer
        actual[k].to_i == v
      when Regexp
        v =~ actual[k].to_s.chomp
      else
        actual[k].to_s.chomp == v.to_s.chomp
      end
    end
  end

  def runnables
    @_runnables ||= @runnables.map { |runnable|
      p runnable
      case runnable.extname
      when '.go'
        GoRunner.new(runnable)
      when '.rb'
        RubyRunner.new(runnable)
      end
    }
  end

  def test_cases
    return @test_cases if defined?(@test_cases)
    TEST_CASES_FILE.exist? or raise "The test cases file at #{TEST_CASES_FILE} doesn't exist"
    @test_cases = YAML.load(TEST_CASES_FILE.read)
  end
end
