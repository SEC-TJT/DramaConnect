# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Password Digestion' do
  it 'SECURITY: create password digests safely, hiding raw password' do
    password = 'secret password of 服務科學研究所 stored in db'
    digest = DramaConnect::Password.digest(password)

    _(digest.to_s.match?(password)).must_equal false
  end

  it 'SECURITY: successfully checks correct password from stored digest' do
    password = 'secret password of 服務科學研究所 stored in db'
    digest_s = DramaConnect::Password.digest(password).to_s

    digest = DramaConnect::Password.from_digest(digest_s)
    _(digest.correct?(password)).must_equal true
  end

  it 'SECURITY: successfully detects incorrect password from stored digest' do
    password1 = 'secret password of 服務科學研究所 stored in db'
    password2 = 'Ifyouwishtomakeapplepieyoumustfirstinventtheuniverse'
    digest_s1 = DramaConnect::Password.digest(password1).to_s

    digest1 = DramaConnect::Password.from_digest(digest_s1)
    _(digest1.correct?(password2)).must_equal false
  end
end
