require "net/http"

class BackgroundRemoverService
  API_URL = URI("https://api.remove.bg/v1.0/removebg")

  def self.call(photo)
    response = post_to_api(photo)
    raise "remove.bg error: #{response.body}" unless response.is_a?(Net::HTTPSuccess)

    build_upload(photo, response.body)
  rescue StandardError => e
    Rails.logger.error("BackgroundRemoverService failed: #{e.message}")
    photo.rewind
    photo
  end

  def self.post_to_api(photo)
    request = Net::HTTP::Post.new(API_URL)
    request["X-Api-Key"] = ENV.fetch("REMOVE_BG_API_KEY")
    request.set_form(form_data(photo), "multipart/form-data")
    Net::HTTP.start(API_URL.host, API_URL.port, use_ssl: true) { |http| http.request(request) }
  end

  def self.form_data(photo)
    [
      ["image_file", photo.read, { filename: photo.original_filename, content_type: photo.content_type }],
      ["size", "auto"]
    ]
  end

  def self.build_upload(photo, body)
    output = Tempfile.new(["no_bg", ".png"])
    output.binmode
    output.write(body)
    output.rewind
    ActionDispatch::Http::UploadedFile.new(
      tempfile: output,
      filename: "#{File.basename(photo.original_filename, '.*')}_no_bg.png",
      type: "image/png"
    )
  end

  private_class_method :post_to_api, :form_data, :build_upload
end
