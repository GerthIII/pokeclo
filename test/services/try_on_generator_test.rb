require "test_helper"

class TryOnGeneratorTest < ActiveSupport::TestCase
  setup do
    @outfit = outfits(:alice_outfit)
    @generator = TryOnGenerator.new(outfit: @outfit, user: users(:alice))
  end

  def run_with(behavior)
    calls = 0
    stub = lambda do |**|
      calls += 1
      behavior.call(calls)
    end
    result = GeminiService.stub(:generate_try_on, stub) { @generator.call }
    [result, calls]
  end

  test "success attaches a photo and returns true" do
    result, calls = run_with(->(_) { StringIO.new("png") })
    assert_equal true, result
    assert_equal 1, calls
    assert @outfit.reload.photo.attached?
  end

  test "a retryable error is retried once, then fails" do
    result, calls = run_with(->(_) { raise RubyLLM::ServerError.new(nil, "boom") })
    assert_not result
    assert_equal 2, calls
  end

  test "a non-retryable error is not retried" do
    result, calls = run_with(->(_) { raise ArgumentError, "bad" })
    assert_not result
    assert_equal 1, calls
  end
end
