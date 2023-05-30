# frozen_string_literal: true

module DramaConnect
  # Policy to determine if account can view a dramalist
  class DramalistPolicy
    # Scope of dramalist policies
    class AccountScope
      def initialize(current_account, target_account = nil)
        target_account ||= current_account
        @full_scope = all_dramalists(target_account)
        @own_scope = owned_dramalists(current_account)
        @share_scope = shared_dramalists(current_account)
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

      def ownable
        @own_scope
      end

      def shareable
        @share_scope
      end

      private

      def owned_dramalists(account)
        account.owned_dramalists.map do |dramalist|
          policy = DramalistPolicy.new(account, dramalist)
          dramalist.to_h.merge(policies: policy.summary)
        end
      end

      def shared_dramalists(account)
        account.visitings.map do |dramalist|
          policy = DramalistPolicy.new(account, dramalist)
          dramalist.to_h.merge(policies: policy.summary)
        end
      end

      def all_dramalists(account)
        puts account.owned_dramalists + account.visitings
        (account.owned_dramalists + account.visitings).map do |dramalist|
          policy = DramalistPolicy.new(account, dramalist)
          dramalist.to_h.merge(policies: policy.summary)
        end
      end

      def includes_visitor?(dramalist, account)
        dramalist.visitors.include? account
      end
    end
  end
end
