require "net/http"

class BackgroundRemoverService
  API_URL = URI("https://api.remove.bg/v1.0/removebg")

  def self.call(photo)
    request = Net::HTTP::Post.new(API_URL)
    request["X-Api-Key"] = ENV.fetch("REMOVE_BG_API_KEY")

    form_data = [
      ["image_file", photo.read, { filename: photo.original_filename, content_type: photo.content_type }],
      ["size", "auto"]
    ]
    request.set_form(form_data, "multipart/form-data")

    response = Net::HTTP.start(API_URL.host, API_URL.port, use_ssl: true) { |http| http.request(request) }

    raise "remove.bg error: #{response.body}" unless response.is_a?(Net::HTTPSuccess)

    output = Tempfile.new(["no_bg", ".png"])
    output.binmode
    output.write(response.body)
    output.rewind

    ActionDispatch::Http::UploadedFile.new(
      tempfile: output,
      filename: "#{File.basename(photo.original_filename, ".*")}_no_bg.png",
      type: "image/png"
    )
  rescue => e
    Rails.logger.error("BackgroundRemoverService failed: #{e.message}")
    photo
  end
end
