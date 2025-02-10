# name: discourse-topic-images
# about: Add images to topic list items
# version: 0.1
# authors: IT-SIMPLE 简单亿点
# url: https://github.com/your-repo

after_initialize do
  add_to_serializer(:topic_list_item, :image_urls) do
    post = object.first_post
    return { urls: [], more_images: false } unless post
    
    urls = Nokogiri::HTML(post.cooked).css('img').map do |img| 
      src = img['src']
      Rails.logger.info "Found image src: #{src}"
      src
    end.uniq

    total_images = urls.length
    {
      urls: urls.first(3),  # 使用first(3)来获取前3个URL
      more_images: total_images > 3  # 如果总数超过3个，返回true
    }
  end
end
