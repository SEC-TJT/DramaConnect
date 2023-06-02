# frozen_string_literal: true

module DramaConnect
  # Add a visitor to another owner's existing dramalist
  class GetAccountList

    def self.call
      accounts = Account.all
      for account in accounts
        account.to_json
      end
    end
  end
end
