require 'code_breaker'

class WelcomeController < ApplicationController
  def index
      render json: {'text': 'application working'}
  end

  def find
      text = params[:text]

      codeBreaker = CodeBreaker.new(text)
      plainText = codeBreaker.decrypt

      ans = {'text': plainText}

      render json: ans
  end
end
