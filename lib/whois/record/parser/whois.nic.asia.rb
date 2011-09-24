#--
# Ruby Whois
#
# An intelligent pure Ruby WHOIS client and parser.
#
# Copyright (c) 2009-2011 Simone Carletti <weppos@weppos.net>
#++


require 'whois/record/parser/base_afilias'


module Whois
  class Record
    class Parser

      # Parser for the whois.nic.asia server.
      class WhoisNicAsia < BaseAfilias

        property_supported :status do
          Array.wrap(node("Domain Status"))
        end


        property_supported :created_on do
          node("Domain Create Date") do |value|
            Time.parse(value)
          end
        end

        property_supported :updated_on do
          node("Domain Last Updated Date") do |value|
            Time.parse(value)
          end
        end

        property_supported :expires_on do
          node("Domain Expiration Date") do |value|
            Time.parse(value)
          end
        end


        property_supported :admin_contacts do
          contact("Administrative", Whois::Record::Contact::TYPE_ADMIN)
        end

        property_supported :technical_contacts do
          contact("Technical", Whois::Record::Contact::TYPE_TECHNICAL)
        end


        property_supported :nameservers do
          Array.wrap(node("Nameservers")).reject(&:empty?).map do |name|
            Nameserver.new(name.downcase)
          end
        end


        private

          def contact(element, type)
            node("#{element} ID") do
              address = ["", "2", "3"].
                  map { |i| node("#{element} Address#{i}") }.
                  delete_if(&:empty?).
                  join("\n")

              Record::Contact.new(
                :type         => type,
                :id           => node("#{element} ID"),
                :name         => node("#{element} Name"),
                :organization => node("#{element} Organization"),
                :address      => address,
                :city         => node("#{element} City"),
                :zip          => node("#{element} Postal Code"),
                :state        => node("#{element} State/Province"),
                :country_code => node("#{element} Country/Economy"),
                :phone        => node("#{element} Phone"),
                :fax          => node("#{element} FAX"),
                :email        => node("#{element} E-mail")
              )
            end
          end

      end

    end
  end
end