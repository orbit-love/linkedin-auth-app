require 'net/http'
require 'json'

class SessionsController < ApplicationController
    def create
      @token = get_token
    end

    def code
      @token = get_token
    end

    private

    def get_token
      uri = URI.parse("https://www.linkedin.com/oauth/v2/accessToken")
      response = Net::HTTP.post_form(uri, {
        :grant_type => 'authorization_code', 
        :code => params[:code], 
        :client_id => ENV["LINKEDIN_CLIENT_ID"], 
        :client_secret => ENV["LINKEDIN_CLIENT_SECRET"],
        :redirect_uri => "#{request.original_url}auth/linkedin/callback"
      })
      
      response = JSON.parse(response.body)

      response["access_token"]
    end
  end