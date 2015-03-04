# coding: utf-8

def get_user(id)
  user = @rest.user(id)
  return {
    :name=> user.name,
    :url=> user.url,
    :location=> user.location,
    :bio=> user.description, 
    :sn=> user.screen_name,
    :icon=> user.profile_image_uri.to_s.gsub("_normal",""),
    :head=> user.profile_banner_uri.to_s.gsub("_normal","")
  }
end