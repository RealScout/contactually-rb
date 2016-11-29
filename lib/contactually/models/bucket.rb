module Contactually
  module Models
    class Bucket
      include Model

      field :contact_count, :integer
      field :created_at, :datetime
      field :goal, :string
      field :id, :string
      field :name, :string
      field :reminder_interval, :integer
      field :updated_at, :datetime

      field :extra_data, Hash

      def contacts
        @contacts ||= Contactually::Contacts.new(url: "/v2/buckets/#{id}/contacts", interface: interface)
      end
    end
  end
end
