module SimulatorHelper
  def return_image_file(data_url)
    str = data_url["data:image/jpeg;base64,".length .. -1]
    if str.to_s.empty?
      path = Rails.root.join("public/img/default.png")
      image_file = File.open(path, "rb")

    else
      jpeg       = Base64.decode64(str)
      image_file = File.new("preview_#{Time.now()}.jpeg", "wb")
      image_file.write(jpeg)
    end

    image_file
  end

  def check_to_delete (data_url)
    !data_url["data:image/jpeg;base64,".length .. -1].to_s.empty?
  end
end
