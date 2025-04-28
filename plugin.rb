# name: discourse-topic-images
# about: Add images to topic list items
# version: 0.1
# authors: IT-SIMPLE 简单亿点
# url: https://github.com/your-repo

after_initialize do
  add_to_serializer(:topic_list_item, :image_urls) do
    post = object.first_post
    return { urls: [], more_images: false } unless post
    
    doc = Nokogiri::HTML(post.cooked)
    
    # 排除投票工具中的图片
    doc.css('.poll-container img, .editorjs-poll-tool img, [data-poll-name] img').each do |poll_img|
      poll_img.remove
    end
    
    # 排除引用内容中的图片和头像
    doc.css('.quote img, .avatar img, img.avatar').each do |quote_img|
      quote_img.remove
    end
    
    urls = doc.css('img').map do |img| 
      src = img['src']
      Rails.logger.info "Found image src: #{src}"
      src
    end.select do |url|
      # 跳过包含emoji和avatar的图片URL
      !url.to_s.include?('emoji') && !url.to_s.include?('avatar')
    end.uniq

    total_images = urls.length
    {
      urls: urls.first(3),  # 使用first(3)来获取前3个URL
      more_images: total_images > 3  # 如果总数超过3个，返回true
    }
  end
end
