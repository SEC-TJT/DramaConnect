# frozen_string_literal: true

module DramaConnect
  # Policy to determine if account can view a dramalist
  class DramalistPolicy
    # Scope of dramalist policies
    class AccountScope
      def initialize(current_account, target_account = nil)
        target_account ||= current_account
        @full_scope = all_dramalists(target_account)
        @current_account = current_account
        @target_account = target_account
      end

      def viewable
        if @current_account == @target_account
          @full_scope
        else
          @full_scope.select do |dral|
            includes_visitor?(dral, @current_account)
          end
        end
      end

      private

      def all_dramalists(account)
        account.owned_dramalists + account.visitings
      end

      def includes_visitor?(dramalist, account)
        dramalist.visitors.include? account
      end
    end
  end
end
