# frozen_string_literal: true

module DramaConnect
  # Maps Github account details to attributes
  class GithubAccount
    def initialize(gh_account)
      @gh_account = gh_account
    end

    def username
      @gh_account['login'] + '@github'
    end

    def email
      @gh_account['email']
    end

    def name # rubocop:disable Lint/DuplicateMethods
      @gh_account['name']
    end
  end
end
