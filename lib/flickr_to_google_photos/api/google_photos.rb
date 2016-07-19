module FlickrToGooglePhotos
  class GooglePhotos

    def initialize(user_id, client_id, client_secret, refresh_token)
      access_token = fetch_access_token(client_id, client_secret, refresh_token)
      @picasa = Picasa::Client.new(user_id: user_id, access_token: access_token)
    end

    def create_album(album)
      created = @picasa.album.create(title: album.title, summary: album.description, access: :private)
      album.update(google_photo_id: created.id)
    end

    def upload_photo(album, photo, binary)
      create_album(album) unless (album.google_id?)

      @picasa.photo.create(album.google_id,
                           binary: binary,
                           content_type: 'image/jpeg',
                           title: photo.title,
                           summary: photo.description)
    end

    private

    def fetch_access_token(client_id, client_secret, refresh_token)
      client = Signet::OAuth2::Client.new(
        client_id: client_id,
        client_secret: client_secret,
        token_credential_uri: "https://www.googleapis.com/oauth2/v3/token",
        refresh_token: refresh_token
      )
      client.refresh!
      client.access_token
    end

  end
end
