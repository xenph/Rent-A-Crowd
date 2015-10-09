require 'sinatra'
require 'redis'
require 'json'

class App < Sinatra::Base
    post '/:context/rest/usermanagement/latest/authentication' do
        redis = Redis.new(:url => ENV["REDIS_URL"])
        users_json = redis.get(params[:context])
        users_json = "{}" if users_json == nil
        @users = JSON.parse(users_json)
        if @users[params[:username]] != nil
                @user = @users[params[:username]]
                status 200
                erb :valid_user
        else
            status 400
            erb :invalid_user
        end
    end

    get '/:context' do
        redis = Redis.new(:url => ENV["REDIS_URL"])
        users_json = redis.get(params[:context])
        users_json = "{}" if users_json == nil
        @users = JSON.parse(users_json)

        erb :show
    end

    post '/:context' do
        redis = Redis.new(:url => ENV["REDIS_URL"])

        users_json = redis.get(params[:context])
        users_json = "{}" if users_json == nil
        users = JSON.parse(users_json)
        users[params[:username]] = {
            username: params[:username],
            first: params[:first],
            last: params[:last],
            display_name: params[:display_name],
            email: params[:email],
            active: params[:active],
        }
        redis.set(params[:context], users.to_json)

        redirect "/#{params[:context]}"
    end
end
