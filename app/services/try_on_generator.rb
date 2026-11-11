# DECISION: Try-on generation and its retry policy live in a service so the controller only handles HTTP.
#   Rejected: a controller concern (passes the linter but only moves the fat).
# 決定: 試着画像の生成とそのリトライ方針はサービスに置き、コントローラーはHTTP処理だけを担当する。
#   却下: コントローラーのconcern(Linterは通るが、肥大化したコードを移動するだけ)。
class TryOnGenerator
  # DECISION: Try-on costs money per call. POST only, at most 2 attempts, and only on network/API errors.
  #   Rejected: background job (better, but a much bigger change for now); sleep between retries (blocks a web thread).
  # 決定: 試着は呼び出しごとに料金がかかる。POSTのみ、最大2回まで、リトライはネットワーク/APIエラーの場合だけ。
  #   却下: バックグラウンドジョブ(より良いが、現時点では変更が大きすぎる)、リトライ間のsleep(Webスレッドを止めてしまう)。
  TRY_ON_ATTEMPTS = 2
  # Same errors ruby_llm treats as transient. Not RubyLLM::Error as a whole: it includes
  # BadRequest/Unauthorized/PaymentRequired/Forbidden, which never succeed on retry.
  # ruby_llmが一時的なエラーとして扱うものと同じ。RubyLLM::Error全体は対象にしない:
  # BadRequest/Unauthorized/PaymentRequired/Forbiddenを含み、これらはリトライしても成功しないため。
  RETRYABLE_AI_ERRORS = [
    RubyLLM::RateLimitError, RubyLLM::ServerError, RubyLLM::ServiceUnavailableError, RubyLLM::OverloadedError,
    Faraday::TimeoutError, Faraday::ConnectionFailed
  ].freeze

  def initialize(outfit:, user:)
    @outfit = outfit
    @user = user
  end

  # Returns true on success, nil after logging a failure.
  # 成功時はtrueを返し、失敗時はログを記録してnilを返す。
  def call
    attach_try_on_image
  end

  private

  def attach_try_on_image(attempt = 1)
    generate_try_on_photo
    true
  rescue *RETRYABLE_AI_ERRORS => e
    return attach_try_on_image(attempt + 1) if attempt < TRY_ON_ATTEMPTS

    log_try_on_failure(e)
  rescue StandardError => e
    log_try_on_failure(e)
  end

  def log_try_on_failure(error)
    Rails.logger.error("Try-on generation failed: #{error.class} - #{error.message}")
    nil
  end

  def generate_try_on_photo
    result = GeminiService.generate_try_on(base: @user.profile_photo, items: @outfit.items.map(&:photo))
    @outfit.photo.attach(io: result, filename: "#{@outfit.id}.png", content_type: "image/png")
  end
end
