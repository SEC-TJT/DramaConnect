# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test AddVisitor service' do
  before do
    wipe_database

    DATA[:accounts].each do |account_data|
      DramaConnect::Account.create(account_data)
    end

    dramalist_data = DATA[:dramalists].first

    @owner_data = DATA[:accounts][0]
    @owner = DramaConnect::Account.all[0]
    @visitor = DramaConnect::Account.all[1]
    @dramalist = @owner.add_owned_dramalist(dramalist_data)
  end

  it 'HAPPY: should be able to add a visitor to a dramalist' do
    auth = authorization(@owner_data)

    DramaConnect::AddVisitor.call(
      auth: auth,
      dramalist: @dramalist,
      visitor_email: @visitor.email
    )

    _(@visitor.dramalists.count).must_equal 1
    _(@visitor.dramalists.first).must_equal @dramalist
  end

  it 'BAD: should not add owner as a visitor' do
    auth = DramaConnect::AuthenticateAccount.call(
      username: @owner_data['username'],
      password: @owner_data['password']
    )
    _(proc {
        DramaConnect::AddVisitor.call(
          auth: auth,
          dramalist: @dramalist,
          visitor_email: @owner.email
        )
      }).must_raise DramaConnect::AddVisitor::ForbiddenError
  end
end
