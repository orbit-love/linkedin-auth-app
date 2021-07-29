require 'net/http'
require 'json'
require 'uri'

class SessionsController < ApplicationController
    def new
      redirect_url = "#{request.base_url}/auth/linkedin/callback"
      loc = get_code_location(redirect_url)
      redirect_to loc["location"] and return if loc["location"]

      flash[:errors] = "Something went wrong ~~ \nLinkedIn API status code: #{loc.code} ~~ \nLinkedIn API response message: #{loc.message}"
      redirect_to :controller => 'pages', :action => 'index'
    end
  
    def create
      puts request.original_url.split('?')[0]
      puts params
      @token = get_token
    end

    def code
      @token = get_token
    end

    private

    def get_code_location(redirect_url)
      url = URI("https://www.linkedin.com/oauth/v2/authorization")
      https = Net::HTTP.new(url.host, url.port)
      https.use_ssl = true

      body = {
        :response_type => 'code', 
        :client_id => ENV["LINKEDIN_CLIENT_ID"], 
        :redirect_uri => redirect_url,
        :scope => "r_organization_social"
        # request.original_url.split('?')[0]
      }

      url.query = URI.encode_www_form(body)
      request = Net::HTTP::Get.new(url)

      response = https.request(request)
    end
    
    def get_token
      url = URI("https://www.linkedin.com/oauth/v2/accessToken")

      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      req = Net::HTTP::Post.new(url)
      req["Accept"] = "*/*"
      req["Content-Type"] = "application/x-www-form-urlencoded"

      req.body = {
        :grant_type => 'authorization_code', 
        :code => "#{params[:code]}", 
        :client_id => ENV["LINKEDIN_CLIENT_ID"], 
        :client_secret => ENV["LINKEDIN_CLIENT_SECRET"],
        :redirect_uri => request.original_url.split('?')[0]
      }

      req.body = URI.encode_www_form(req.body)

      response = http.request(req)

      response = JSON.parse(response.body)

      response["access_token"]
    end
  end