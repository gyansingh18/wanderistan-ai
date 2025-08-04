class Video < ApplicationRecord
  belongs_to :place

  validates :youtube_url, presence: true, format: { with: /\Ahttps:\/\/www\.youtube\.com\/watch\?v=[\w-]+\z/, message: "must be a valid YouTube URL" }
  validates :title, presence: true
  validates :thumbnail_url, presence: true

  def video_id
    youtube_url.split('v=').last
  end

  def embed_url
    "https://www.youtube.com/embed/#{video_id}"
  end
end
