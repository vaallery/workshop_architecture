module Legacy
  class Program < Legacy::ApplicationRecord
    include Authority::Abilities
    include TranslateEnum
    include PhpDeserialization
    include ProgramUrlHelper

    has_paper_trail only: [:url, :urlcode, :education_format_type].freeze

    B2B_COURSE_LIBRARY_URL = "course_library"
    B2B_SCORM_URL = "b2b-scorm"
    B2B_LEADER_360_URL = "b2b-lider-360"
    B2B_DEMO_LEADER_360_URL = "lider-360-full-demo"
    B2B_PRODUCT_URLS = [
      B2B_SCORM_URL,
      B2B_COURSE_LIBRARY_URL,
      B2B_LEADER_360_URL
    ]
    MINDBOX_CATEGORY_KEY = "mindbox_offer_categories"
    HELP_CENTER_URLS = %w[b2b_help_center]
    URL_REGEX =
      %r@
        \A(http|https)://
        [a-z0-9]+([\-\._][a-z0-9]+)*
        \.[a-z]{2,63}
        (:\d{1,5})?
        (/.*)?\z
      @ix

    COLOR_HEX_CODES = {
      1 => "#50b9e1",
      2 => "#299e4e",
      3 => "#fe9c00",
      4 => "#9d6cbf",
      5 => "#3d4f95",
      6 => "#d95452",
      7 => "#f94542",
      8 => "#785eab"
    }.freeze

    DISTANCE_COURSE_ATTRIBUTES_TYPES = %w[
      online_program_attribute_collection
      offline_program_attribute_collection
      profession_attribute_collection
    ].freeze

    self.inheritance_column = :_type_disabled

    enum complexity: {
      :no => 0,
      :base => 1,
      :middle => 2,
      :expert => 3
    }
    translate_enum :complexity

    enum type: {
      distance_course: "distance-course",
      webinar: "webinar",
      video_course: "mini-course",
      subprogram: "course-subprogram",
      training: "training",
      online_conference: "online-conference"
    }
    translate_enum :type

    enum certificate_type: {
      certificate: "certificate",
      diploma: "diploma",
      guarantee: "guarantee"
    }
    translate_enum :certificate_type

    enum official_document: {
      certificate: "certificate",
      diploma: "diploma",
      nothing: "nothing"
    }, _prefix: :document
    translate_enum :official_document

    enum education_format_type: {
      full_time: "full_time",
      online: "online",
      asynchronous: "asynchronous"
    }
    translate_enum :education_format_type

    enum trajectory: {
      old_format: "old_format",
      lesson: "lesson",
      lessons: "lessons",
      modules: "modules",
      not: "not"
    }, _suffix: :trajectory
    translate_enum :trajectory

    # Данный enum ссылается на колонку active в БД
    # При update-е надо использовать "active". Поля "status" в БД нет
    enum status: {
      :only_crm => 0,
      :published => 1,
      :available_by_direct_link => 2,
      :in_develop => 3,
      :archived => 4
    }
    def active
      self.class.statuses.key(read_attribute(:active))
    end
    alias_method :status, :active

    statuses.each do |name, index|
      define_method("#{name}?") { active == name }
      define_method("#{name}!") { self.active = index }
      scope(name, -> { where(active: index) })
    end

    enum format_type: [:old_format, :new_format]
    translate_enum :format_type

    php_deserialize :add_data, :texts

    mount_uploader :partner_logo, ::Programs::PartnerLogoUploader
    mount_uploader :pdf_file, PdfUploader
    mount_uploader :image, ProgramImageUploader

    belongs_to :program_family, optional: true, touch: true
    belongs_to :attribute_collection, optional: true, polymorphic: true
    belongs_to :curator_user, class_name: "Legacy::User", optional: true, foreign_key: :curator_id
    belongs_to :curator_assistant_user, class_name: "Legacy::User", optional: true, foreign_key: :another_curator_id
    belongs_to :host, class_name: "Legacy::User", optional: true
    belongs_to :producer, class_name: "Legacy::User", optional: true
    belongs_to :deleted_by, class_name: "Legacy::User", optional: true
    belongs_to :program_type, optional: true

    has_one :approved_program_reference, class_name: "EP::ApprovedProgramReference", foreign_key: :program_id
    has_one :meta, as: :resource, class_name: "Legacy::Metadata", dependent: :delete
    has_one :current_family, class_name: "Legacy::ProgramFamily", foreign_key: :current_program_id
    has_one :termination, class_name: "LMS::Programs::Termination", dependent: :destroy
    has_one :payment_instruction, class_name: "LMS::Programs::PaymentInstruction", dependent: :destroy
    has_one :main_direction, class_name: "Legacy::Direction", through: :program_family
    has_one :main_alt_direction, class_name: "Legacy::Direction", through: :program_family
    has_one :show_direction, class_name: "LandingDirection", through: :program_family
    has_one :landing_main_direction, class_name: "LandingDirection", through: :program_family
    has_one :company, class_name: "::Company", through: :main_direction
    has_one :comment_form, dependent: :destroy
    has_one :free_program_setting, dependent: :destroy
    has_one :subscription_tariff, class_name: "Subscriptions::Tariff", dependent: :restrict_with_error
    has_one :diploma_documents_settings_set, class_name: "Programs::DiplomaDocuments::SettingsSet", dependent: :nullify
    has_one :old_videocourse_rating
    has_one :module_reference, class_name: "EP::ModuleReference", foreign_key: :linked_program_id

    has_many :access_state, as: :last_creating_initiator, dependent: :restrict_with_error
    has_many :access_logs, as: :initiator, dependent: :restrict_with_error
    has_many :termination_rules, class_name: "LMS::Programs::TerminationRule", dependent: :destroy
    has_many :user_terminations, class_name: "LMS::Programs::UserTermination", dependent: :destroy
    has_many :payment_terms, class_name: "LMS::Programs::PaymentTerm", through: :payment_instruction, dependent: :destroy

    has_many :directions, -> { distinct }, through: :program_family
    has_many :landing_directions, -> { distinct }, through: :program_family
    has_many :mc_programs, class_name: "Legacy::McProgram", foreign_key: :course_id
    has_many :orders, class_name: "Legacy::Order", dependent: :restrict_with_error
    has_many :with_access_orders, -> { roots.with_access }, class_name: "Legacy::Order", dependent: :restrict_with_error
    has_many :online_webinars, dependent: :destroy
    has_many :parent_program_seminars, inverse_of: :program, class_name: "Legacy::Seminar", foreign_key: :parent_program_id, dependent: :destroy
    has_many :payable_events, class_name: "LMS::Programs::PayableEvent", dependent: :destroy

    has_many :profession_to_programs, class_name: "Legacy::ProfessionToProgram", foreign_key: :profession_id, dependent: :destroy
    has_many :profession_to_programs_for_program, class_name: "Legacy::ProfessionToProgram", foreign_key: :program_id, dependent: :destroy
    has_many :professions, through: :profession_to_programs_for_program
    has_many :program_files, dependent: :destroy
    has_many :programs, through: :profession_to_programs
    has_many :profession_modules, class_name: "::Programs::ProfessionModule", foreign_key: :profession_id, dependent: :delete_all
    has_many :seminars, dependent: :destroy

    has_many :subscription_programs, class_name: "Subscriptions::SubscriptionProgram", dependent: :restrict_with_error
    has_many :subscription_tariff_programs, class_name: "Subscriptions::TariffProgram", dependent: :restrict_with_error

    has_many :diplomas, dependent: :destroy
    has_many :diploma_requests, dependent: :restrict_with_error
    has_many :diploma_issuances, dependent: :nullify
    has_many :certificates, dependent: :nullify

    has_many :user_reviews, dependent: :destroy, foreign_key: :course_id
    has_many :user_mc_status, dependent: :destroy
    has_many :navigational_program_tags_programs, dependent: :destroy
    has_many :navigational_program_tags, through: :navigational_program_tags_programs
    has_many :lessons, dependent: :destroy, foreign_key: :course_id
    has_many :user_to_mc_programs, dependent: :destroy, foreign_key: :course_id
    has_many :tests, dependent: :destroy, class_name: "Legacy::Test"
    has_many :final_tests, dependent: :destroy, class_name: "Legacy::Test", foreign_key: :parent_program_id
    has_many :lms_lessons, class_name: "LMS::Lesson", dependent: :destroy
    has_many :lesson_items, dependent: :destroy, class_name: "LMS::LessonItem"
    has_many :lms_webinars, through: :lesson_items, source: :resource, source_type: "LMS::LessonResources::Webinar"
    has_many :lms_texts, through: :lesson_items, source: :resource, source_type: "LMS::LessonResources::Text"
    has_many :lms_videos, through: :lesson_items, source: :resource, source_type: "LMS::LessonResources::Video"
    has_many :lms_tasks, through: :lesson_items, source: :resource, source_type: "LMS::LessonResources::Task"
    has_many :lms_offline_lectures, through: :lesson_items, source: :resource, source_type: "LMS::LessonResources::OfflineLecture"
    has_many :tasks, dependent: :destroy
    has_many :parent_program_tasks, class_name: "Legacy::Task", foreign_key: :parent_program_id, dependent: :destroy
    has_many :expert_incomes, dependent: :restrict_with_error
    has_many :seminar_days, dependent: :delete_all
    has_many :payout_lists, dependent: :destroy
    has_many :blocks, class_name: "LMS::Block", dependent: :destroy
    has_many :videos, dependent: :destroy
    has_many :resource_packages, class_name: "LMS::Programs::ResourcePackage", dependent: :destroy
    has_many :program_recomended_program_families, dependent: :destroy
    has_many :recomended_program_families, through: :program_recomended_program_families
    has_many :vk_callback_api_lead_forms, class_name: "VkCallbackAPILeadForm", dependent: :delete_all
    has_many :shared_diplomas, dependent: :destroy
    has_many :private_faqs, class_name: "Legacy::PrivateProgramFaq", dependent: :delete_all
    has_many :comment_form_results, through: :comment_form
    has_many :student_groups, dependent: :delete_all, class_name: "LMS::Students::Group", as: :resource, inverse_of: :resource
    has_many :groups_templates, class_name: "LMS::Students::GroupsTemplate"
    has_many :user_poll_results, class_name: "LMS::Polls::UserPollResult", dependent: :restrict_with_exception
    has_many :faqs, class_name: "Legacy::ProgramFaq", dependent: :delete_all
    has_many :faqlks, class_name: "Legacy::ProgramFaqlk", dependent: :delete_all
    has_many :citations, class_name: "Legacy::Citation", dependent: :delete_all
    has_many :promos, class_name: "Legacy::ProgramPromo", dependent: :delete_all
    has_many :promo_texts, class_name: "Legacy::ProgramPromoText", dependent: :delete_all
    has_many :product_prices, dependent: :delete_all, as: :resource
    has_many(
      :current_product_prices,
      -> do
        where("starts_at <= :t AND stops_at > :t", t: Time.zone.now.to_s(:nozone))
        .not_removed
        .program_prices
        .order(starts_at: :desc)
      end,
      class_name: "ProductPrice", as: :resource
    )

    has_many :program_employees, class_name: "LMS::Programs::ProgramEmployee", dependent: :delete_all
    has_many :employees, through: :program_employees

    has_many :coordinators_incomes, class_name: "Payouts::Coordinators::CoordinatorIncome", dependent: :restrict_with_error

    has_many :program_coordinators, -> { coordinator }, class_name: "LMS::Programs::ProgramEmployee"
    has_many :coordinators, through: :program_coordinators, source: :employee
    has_many :coordinator_working_logs, class_name: "Payouts::Coordinators::ProgramWorkingLog"
    has_many :program_graduates, -> { graduate }, class_name: "LMS::Programs::ProgramEmployee"
    has_many :graduates, through: :program_graduates, source: :employee

    has_many :profession_for_program_family_in_professions, -> { order(position: :asc) }, class_name: "Legacy::ProfessionForProgramFamilyInProfession", dependent: :delete_all, foreign_key: :profession_id
    has_many :in_profession_families, through: :profession_for_program_family_in_professions, source: :program_family

    has_many :help_desk_tickets, as: :request_resource, class_name: "HelpDesk::Ticket", dependent: :restrict_with_error
    has_one :help_desk_product, as: :resource, class_name: "HelpDesk::Product", dependent: :restrict_with_error
    has_many :assigned_coordinators, through: :help_desk_product, source: :coordinators, class_name: "Legacy::User"

    has_one :common_access_level, -> { active.common }, class_name: "LMS::Programs::AccessLevel"
    has_one :demo_access_level, -> { active.demo }, class_name: "LMS::Programs::AccessLevel"

    has_many :access_levels, class_name: "LMS::Programs::AccessLevel", dependent: :destroy
    has_many :access_states, -> { with_access }, through: :access_levels, source: :access_states # TODO: remove this
    has_many :levels_access_states, -> { with_access }, through: :access_levels, source: :access_states
    has_many :common_level_access_states, -> { with_access }, through: :common_access_level, source: :access_states
    has_many :students, -> { distinct }, through: :levels_access_states, source: :user
    has_many(
      :graduate_students,
      -> do
        joins(:programs_passed_user_terminations)
          .where(LMS::Programs::UserTermination.arel_table[:program_id].eq(LMS::Programs::AccessLevel.arel_table[:program_id]))
          .distinct
      end,
      through: :levels_access_states,
      source: :user
    )
    has_many :levels_all_access_states, through: :access_levels, source: :all_access_states
    has_many :all_students, -> { distinct }, through: :levels_all_access_states, source: :user
    has_many :common_level_students, -> { distinct }, through: :common_level_access_states, source: :user
    has_many :cart_items, as: :resource, class_name: CartItem.to_s
    has_many :user_graduation_events, dependent: :destroy

    has_many :program_experts, class_name: "ProgramExpert"
    has_many :experts, through: :program_experts, source: :user, class_name: "Legacy::User"
    has_many :study_periods, class_name: "LMS::Programs::StudyPeriod", dependent: :nullify
    has_many :duration_changes, class_name: "LMS::Programs::DurationChange", dependent: :nullify
    has_many :notifications_messages, class_name: "Notifications::Message", dependent: :restrict_with_error
    has_many :yandex_feed_program_plans, through: :program_family
    has_many :user_segmentations, class_name: "LMS::Programs::UserSegmentation", dependent: :destroy
    has_many :segmentation_events, class_name: "LMS::Programs::SegmentationEvent", dependent: :destroy

    has_many :root_unti_mappings, class_name: "University2035::ProgramsMapping", foreign_key: :root_program_id, dependent: :destroy
    has_many :leaf_unti_mappings, class_name: "University2035::ProgramsMapping", foreign_key: :leaf_program_id, dependent: :destroy

    has_many :diploma_documents_blocks, class_name: "Programs::DiplomaDocuments::Block", dependent: :nullify
    has_many :finance_expert_planned_payouts, class_name: "Finance::ExpertPlannedPayout", dependent: :restrict_with_error

    has_many :coordinator_to_programs, class_name: "Legacy::CoordinatorToProgram", dependent: :destroy
    has_many :content_coordinators, through: :coordinator_to_programs, source: :coordinator, class_name: "Legacy::User"

    has_many :b2b_promo_codes, class_name: "B2B::Models::PromoCode", dependent: :destroy

    has_many :user_learning_locks, class_name: "LMS::UserLearningLock", dependent: :delete_all

    has_and_belongs_to_many :program_tags, class_name: "Legacy::ProgramTag", join_table: "program_to_tag", association_foreign_key: :tag_id
    has_and_belongs_to_many :presents, class_name: "Legacy::Present", join_table: :present_to_program, association_foreign_key: :present_id

    validates :url_to_replace, format: { with: URL_REGEX }, allow_blank: true

    attribute :experts_count, default: 0

    scope :our, -> { where(owner_id: 0) }
    scope :online_intensive, -> { where(type: "distance-course") }
    scope :video_course, -> { where(type: "mini-course") }
    scope :not_finished, -> { where("programs.finishes_at >= ?", Time.current).or(where(education_format_type: "asynchronous")) }
    scope :actual, -> { where(actual: true) }
    scope :available_for_view_by_users, -> { where(active: [1, 2]) }
    scope :professions, -> { where(profession: true) }
    scope :not_professions, -> { where(profession: false) }
    scope :uncompleted, -> { where(completed: false) }
    scope :completed, -> { where(completed: true) }
    scope :not_edmarket, -> { left_joins(:main_direction).where("COALESCE(directions.company_id, 0) != :edmarket_id", edmarket_id: Company.edmarket_company_id) }
    scope :deleted, -> { where.not(deleted_at: nil) }
    scope :not_deleted, -> { where(deleted_at: nil) }
    scope :payable, -> { where(id: ProductPrice.program_prices.where("price > 0").select(:resource_id)) }
    scope :not_payable, -> { where.not(id: ProductPrice.program_prices.where("price > 0").select(:resource_id)) }
    scope :asynchronous, -> { where(education_format_type: "asynchronous") }
    scope :in_time_period, ->(time_period_start, time_period_end) { where(finishes_at: time_period_start..time_period_end).or(where(starts_at: time_period_start..time_period_end)) }

    scope :tripwire, -> do
      where(
        program_family_id:
          Legacy::ProgramFamily
            .joins(:program_family_attribute_collection)
            .where(Legacy::ProgramFamilyAttributeCollection.arel_table[:price_type].eq("tripwire"))
            .where(Legacy::ProgramFamily.arel_table[:id].eq(Legacy::Program.arel_table[:program_family_id]))
            .select(:id)
      )
    end

    scope :not_tripwire, -> do
      where.not(
        program_family_id:
          Legacy::ProgramFamily
            .joins(:program_family_attribute_collection)
            .where(Legacy::ProgramFamilyAttributeCollection.arel_table[:price_type].eq("tripwire"))
            .where(Legacy::ProgramFamily.arel_table[:id].eq(Legacy::Program.arel_table[:program_family_id]))
            .select(:id)
      )
    end

    scope :with_video_or_not_ends_in_future, -> do
      left_joins(:videos, :lms_webinars, lms_offline_lectures: :video_fragments)
        .where(
          [
            "DATE(programs.finishes_at) >= ?",
            "`video`.`code` IS NOT NULL",
            "`lms_lesson_resources_webinars`.`video_url` IS NOT NULL",
            "`lms_lesson_resources_offline_lectures`.`id` IS NOT NULL"
          ].join(" OR "),
          Time.zone.today
        )
        .distinct
    end

    scope :recommended, -> do
      recommended_programs_ids_data = JsonStorage.serialized_data_for(JsonStorage::RECOMMENDED_PROGRAMS_KEY)
      by_id_list(recommended_programs_ids_data)
    end

    scope :by_id_list, ->(ids) do
      ids_list_is_safe = ids.is_a?(Array) && ids.all? { |id| id.is_a?(Integer) && id.positive? }
      return none unless ids_list_is_safe

      where(id: ids)
    end

    ransack_alias :price_type, :program_family_program_family_attribute_collection_price_type
    ransack_alias :educational_level, :program_family_educational_level_slug
    ransack_alias :skill, :program_family_catalog_skills_slug
    ransack_alias :program_tag, :program_family_program_tags_alias

    ransacker :duration_in_months do |parent|
      starts_at = parent.table[:starts_at]
      finishes_at = parent.table[:finishes_at]
      starts_at_and_finishes_at_present = starts_at.not_eq(nil).and(finishes_at.not_eq(nil))
      month_literal = Arel::Nodes::SqlLiteral.new("MONTH")
      duration_in_months_by_start_and_finish = Arel::Nodes::NamedFunction.new(
        "TIMESTAMPDIFF", [month_literal, starts_at, finishes_at]
      )

      duration_days = parent.table[:duration_days]
      days_in_month = 30
      duration_in_months = Arel::Nodes::Division.new(duration_days, days_in_month)
      duration_in_months_by_duration_days = Arel::Nodes::NamedFunction.new("ROUND", [duration_in_months])

      Arel::Nodes::Case.new
        .when(starts_at_and_finishes_at_present).then(duration_in_months_by_start_and_finish)
        .when(duration_days.not_eq(nil)).then(duration_in_months_by_duration_days)
    end

    scope :join_directions_for_filters, -> do
      # NOTE: default association using 'directions' and in ransack for catalog "directions" are joined by "main_dorection_id". It results to wrong selection
      joins(program_family: :direction_program_families)
        .joins("JOIN landing_directions AS directions_for_filter ON directions_for_filter.id = direction_program_families.landing_direction_id")
    end

    scope :direction_id_in, ->(*ids) do
      join_directions_for_filters.where(directions_for_filter: { id: ids })
    end

    scope :direction_slug_in, ->(*slugs) do
      join_directions_for_filters.where(directions_for_filter: { slug: slugs })
    end

    scope :direction_slug_eq, ->(slug) do
      join_directions_for_filters.where(directions_for_filter: { slug: slug })
    end

    scope :fulltext_search, ->(text) do
      Mobile::ProgramsCatalog::FulltextSearchQuery.call(self, search_string: text)
    end

    scope :duration_in_minutes_gteq, ->(minutes) do
      Mobile::ProgramsCatalog::TotalDurationQuery.new(self, minutes).gteq
    end

    scope :duration_in_minutes_lt, ->(minutes) do
      Mobile::ProgramsCatalog::TotalDurationQuery.new(self, minutes).lt
    end

    delegate :course?, :lesson?, :specialization?, :profession?, :master?, to: :program_type, allow_nil: true, prefix: :type

    after_initialize :set_default_values, if: :new_record?

    def self.authorizer
      Legacy::ProgramAuthorizer
    end

    def self.ransackable_scopes(auth_object = nil)
      # NOTE: https://activerecord-hackery.github.io/ransack/going-further/other-notes/#authorization-allowlistingdenylisting
      case auth_object
      when :mobile
        %i[
          direction_slug_in
          direction_id_in
          fulltext_search
          duration_in_minutes_gteq
          duration_in_minutes_lt
        ]
      when :api
        %i[
          direction_slug_eq
        ]
      else
        super
      end
    end

    def self.ransackable_associations(auth_object = nil)
      # NOTE: https://activerecord-hackery.github.io/ransack/going-further/other-notes/#authorization-allowlistingdenylisting
      return super unless auth_object == :mobile # чтобы не сломать рансакер в других местах

      super & %w[
        program_family
        program_type
      ]
    end

    def self.ransackable_attributes(auth_object = nil)
      # NOTE: https://activerecord-hackery.github.io/ransack/going-further/other-notes/#authorization-allowlistingdenylisting
      return super unless auth_object == :mobile # чтобы не сломать рансакер в других местах

      super & %w[
        id
        price_type
        educational_level
        skill
        program_type
        duration_in_months
        starts_at
        program_tag
      ]
    end

    def self.ransackable_scopes_skip_sanitize_args
      %i[
        duration_in_minutes_gteq
        duration_in_minutes_lt
      ]
    end

    def study_starts_at
      dynamic_start? ? dynamic_starts_at : starts_at
    end

    def format_date(date)
      return if date.blank?

      date.in_time_zone("Moscow").to_date
    end

    def start_date
      format_date(starts_at)
    end

    def dynamic_start_date
      format_date(dynamic_starts_at)
    end

    def finish_date
      format_date(finishes_at)
    end

    def stripped_url
      url.gsub(/-?[0-9]{1,10}$/, "").downcase
    end

    def stripped_urlcode
      (urlcode || "").gsub(/-?[0-9]{1,10}$/, "").downcase
    end

    def edmarket?
      main_direction.present? && main_direction.company_id == Company.edmarket_company_id
    end

    def additional_block_resource
      case format_type.to_s.to_sym
      when :old_format
        Legacy::ProgramSubject
          .where(id: parent_program_seminars.pluck(:program_subject_id).uniq)
          .where("price > 0")
          &.last
      when :new_format
        resource_packages.paid_block.available_for_users&.last
      end
    end

    def has_additional_block?
      additional_block_resource.present?
    end

    def additional_block_price
      case format_type.to_s.to_sym
      when :old_format
        Legacy::ProgramSubject.left_joins(seminars: :parent_program).where(programs: { id: id }).sum(:price)
      when :new_format
        resource_packages.paid_block.available_for_users.sum(:price)
      end.to_i
    end

    def intensive_type
      if type_profession?
        :profession
      elsif full_time?
        :offline
      else
        :online
      end
    end

    def product_type
      if webinar?
        "free-lesson"
      elsif video_course?
        "video-course"
      elsif profession?
        "profession"
      elsif subprogram?
        "lesson"
      else
        "course"
      end
    end

    def color_hex_code
      return color if color.present?

      COLOR_HEX_CODES.fetch(color_scheme, "#fff")
    end

    def curator
      curator_uid =
        if chat_through_assistant? && another_curator_id.present?
          another_curator_id
        else
          curator_id
        end
      return unless curator_uid

      Legacy::User.find_by(id: curator_uid)
    end

    def can_link_to_family?(program_family)
      program_family.present? && url.match?(/^#{program_family.url}/i)
    end

    # со студентами общается ассистент куратора?
    def chat_through_assistant?
      add_data[:chat_with_students] == "assistant"
    end

    def who_communicates_with_students
      add_data[:chat_with_students]
    end

    def attribute_collection_type
      case type
      when "video_course"
        "video_course_attribute_collection"
      when "webinar"
        "webinar_attribute_collection"
      when "distance_course"
        case intensive_type
        when :online
          "online_program_attribute_collection"
        when :offline
          "offline_program_attribute_collection"
        when :profession
          "profession_attribute_collection"
        end
      end
    end

    def build_attribute_collection
      return attribute_collection if attribute_collection

      case type
      when "video_course"
        ProgramAttributeCollections::VideoCourseAttributeCollection.new
      when "webinar"
        ProgramAttributeCollections::WebinarAttributeCollection.new
      when "distance_course"
        case intensive_type
        when :online
          ProgramAttributeCollections::OnlineProgramAttributeCollection.new
        when :offline
          ProgramAttributeCollections::OfflineProgramAttributeCollection.new
        when :profession
          ProgramAttributeCollections::ProfessionAttributeCollection.new
        end
      end
    end

    def can_use_new_lms_struct?
      distance_course? && !profession
    end

    def supports_copying_as_target?
      new_format?
    end

    def active_program?
      published? || available_by_direct_link?
    end

    def priority_by_state
      case free_lesson_status
      when :online
        1
      when :registered
        2
      else
        3
      end
    end

    def lesson_locked_for?(lesson, user = nil)
      lessons_locked_service(user).locked?(lesson)
    end

    def free?
      return true if webinar?
      return false unless distance_course?

      current_price&.zero?
    end

    def base_price
      product_prices.first&.price || 0
    end

    def current_price
      if video_course?
        Legacy::Orders::Prices::Calculators::VideoCourse::FIXED_RUR_AMOUNT_PER_STUDENT
      else
        obj_current_price&.price || 0
      end
    end

    def current_ot_price
      obj_current_price&.ot_price || current_price
    end

    def ot_discount_percent
      return 0 if current_price.zero?

      ((1 - (BigDecimal(current_ot_price) / BigDecimal(current_price))) * 100)
    end

    def obj_current_price
      prices = current_product_prices
      prices.find(&:marketing_campaign?) || prices.first
    end

    def obj_current_and_future_prices
      return [ProductPrice.new(:starts_at => Date.new(2013, 1, 1), :price => ::Legacy::Scorm::NETOLOGY_COURSE_PRICE)] if video_course?

      product_prices.not_removed.where("starts_at >= ?", DateTime.now).order(starts_at: :asc).to_a.unshift(obj_current_price).compact
    end

    def max_intensiv_price
      @max_intensiv_price ||= video_course? ? ::Legacy::Scorm::NETOLOGY_COURSE_PRICE : (product_prices.find_by(price_type: "maximal")&.price || 0)
    end

    def max_price
      @max_price ||= price_limits.to_i
    end

    def next_product_price_obj
      @next_product_price_obj ||=
        if obj_current_price&.marketing_campaign?
          target_price =
            product_prices
              .not_removed
              .target
              .where("starts_at < ?", obj_current_price.stops_at + 1.day)
              .order(starts_at: :desc)
              .first

          target_price || product_prices.not_removed.maximal.last
        else
          product_prices.not_removed.where("starts_at > ?", Time.zone.now.to_s(:nozone)).order(starts_at: :asc).first
        end
    end

    def next_intensive_price
      @next_intensive_price ||= next_product_price_obj&.price || base_price
    end

    def nearest_price_up_date
      @nearest_price_up_date ||=
        if obj_current_price&.marketing_campaign?
          obj_current_price.stops_at + 1.day
        else
          product_prices.not_removed.where("starts_at > ?", Time.zone.now.to_s(:nozone)).minimum(:starts_at)
        end
    end

    def submit_order_url
      "#{APP_CONFIG.hosts.netology}/orderaddactionajax"
    end

    def checkout_step_with_order_for(user:)
      order =
        orders
          .not_free
          .where.not(status: :double)
          .order(id: :desc)
          .find_by(user: user)

      step =
        if access_states.where(user: user).exists?
          :purchased
        elsif user.blank? || user.has_crm_access? || order.blank? || order.cancelled? || order.incorrect?
          :not_registered
        elsif !order.want_paid_blocks? && free?
          :purchased
        elsif !order.requires_payment?
          :purchased
        elsif order.installment?
          :waiting_credit
        else
          :not_purchased
        end

      [step, order]
    end

    def can_expert_incomes_with_terms?
      expert_incomes.where(payment_term_id: nil).none?
    end

    def allowed_for_register?
      return false unless active_program?

      !distance_course? || Legacy::Program
                             .left_outer_joins(current_family: :program_family_attribute_collection)
                             .where(id: id)
                             .where(Legacy::Programs::LatestQuery.new.dates_clause)
                             .exists?
    end

    def accepts_promo_codes?
      !(promocodes_forbidden? ||
        main_direction&.company&.promocodes_forbidden? ||
        NavigationPromotion.active.with_disabled_promo_codes.exists?)
    end

    def payment_methods_gavnomapping
      sum = current_price

      a =
        [
          { title: "Банковская карта", slug: "creditCard", note: "" },
          { title: "По счету от юрлица", slug: "company", note: "" },
          { title: "Кредит от Яндекс.Кассы", slug: "yandexKassaCredit", note: "4 месяца без %", terms: terms(sum, :yandex_installment) },
          { title: "Кредит от Сбербанка", slug: "sberbankCredit", note: "", terms: terms(sum, :sberbank_credit) },
          { title: "Webmoney", slug: "webmoney", note: "" },
          { title: "Яндекс.Деньги", slug: "yandexMoney", note: "" },
          { title: "Альфа-Клик", slug: "alfaClick", note: "" },
          { title: "Система быстрых платежей", slug: "sbp", note: "" },
          { title: "Рассрочка от Сбербанка", slug: "sberCredit", note: "", terms: terms(sum, :sberbank_installment) },
          { title: "Рассрочка от Тинькофф", slug: "tinkoffCredit", note: "", terms: terms(sum, :tinkoff_installment) },
          { title: "Пос-кредит", slug: "posCredit", note: "", terms: terms(sum, :pos_credit_installment) },
          { title: "МТС кредитный брокер", slug: "mtsCreditBroker", note: "", terms: terms(sum, :mts_credit_broker_installment) }
        ]

      a.reject { |payment_method| payment_method.key?(:terms) && payment_method[:terms].nil? }
      a = [reccurent_payment_method] if program_family&.url == Legacy::ProgramFamily::SUBSCRIPTION_PROGRAM_URL

      a
    end

    def reccurent_payment_method
      installment_recurrent_service = Installments::DefineInstallmentPartsByRecurrentService.new(product: self)
      installment_parts = installment_recurrent_service.installment_parts
      payment = installment_parts.first

      {
        title: "Рассрочка от Нетологии",
        slug: "recurrent",
        note: "",
        terms: {
          values: [{ term: installment_parts.count, payment: payment[:amount], payment_without_discount: payment[:amount] }],
          recommended: { term: installment_parts.count, payment: payment[:amount], payment_without_discount: payment[:amount] }
        }
      }
    end

    def terms(sum, payment_method)
      ::CreditTerms::GenerateTerms.new(
        sum: sum,
        sum_without_discount: max_intensiv_price,
        payment_method: payment_method,
        company_slug: main_company_slug,
        program: self
      ).perform
    end

    def min_credit_payment_sum
      Payments::MinCreditPaymentSumService.new(
        price: current_price,
        max_price: max_intensiv_price,
        company_slug: main_company_slug,
        program: self
      ).perform
    end

    def credit_term_by_min_payment
      Payments::MinCreditPaymentSumService.new(
        price: current_price,
        max_price: max_intensiv_price,
        company_slug: main_company_slug,
        program: self
      ).min_terms&.dig(:term)
    end

    def main_company_slug
      ::Products::DefineCompanySlugService.call(self)
    end

    def deleted?
      deleted_at.present?
    end

    def source_meet_lesson_item
      @source_meet_lesson_item ||=
        LMS::LessonItem
          .active
          .where(resource_type: ["LMS::LessonResources::Webinar", "LMS::LessonResources::OfflineLecture"], program_id: id)
          .joins(:lesson)
          .order(LMS::Lesson.arel_table[:position].asc, LMS::LessonItem.arel_table[:position].asc)
          .first
    end

    def mindbox_category_hash
      @mindbox_category_hash ||= ::JsonStorage.find_by(key: MINDBOX_CATEGORY_KEY)&.serialized_data&.dig(program_type&.slug)&.deep_symbolize_keys || {}
    end

    def save_in_mindbox
      Container["mindbox.operation"].call("EditProductAPI", **Mindbox::Views::Legacy::Program.new(self).represent)
    end

    def homeworks_from_student(user, status = nil)
      statuses = status.present? ? [status] : LMS::Tasks::Homework.statuses.keys

      homeworks.filter do |h|
        h.status.in?(statuses) && (h.user_id == user.id || (h.group&.groups_users || []).any? { |gu| gu.user_id == user.id })
      end
    end

    def homeworks
      @homeworks ||=
        LMS::Tasks::Homework
          .joins(lesson_task: :lesson_item)
          .merge(lesson_items)
          .includes(group: :groups_users)
    end

    def user_tests_from_student(user, status = nil)
      statuses = status.present? ? [status] : LMS::Tests::UserTest.statuses.keys

      user_tests.filter do |ut|
        ut.status.in?(statuses) && (ut.user_id == user.id)
      end
    end

    def user_tests
      @user_tests ||=
        LMS::Tests::UserTest
          .joins(lesson_test: :lesson_item)
          .merge(lesson_items)
    end

    def starting_soon?
      return false if starts_at.blank?
      return true if current_family.present? && starts_at < Time.current

      (Time.current..6.days.from_now).cover?(starts_at)
    end

    def can_use_termination_rules?
      lessons_trajectory? || modules_trajectory?
    end

    def free_lesson_status
      if free_lesson_online_now?
        :online
      elsif free_lesson_finished?
        :finished
      else
        :registered
      end
    end

    def free_lesson_online_now?
      return false if starts_at.nil? || finishes_at.nil?

      ((starts_at - 15.minutes)..finishes_at).cover?(Time.current)
    end

    def free_lesson_finished?
      return false if finishes_at.nil?

      Time.current >= finishes_at
    end

    def user_access_states(user)
      ::AccessState.with_access.where(user: user, resource: access_levels)
    end

    def deprecated_meta
      deserialize_column(read_attribute(:meta))
    end

    def user_all_access_states(user)
      ::AccessState.where(user: user, resource: access_levels)
    end

    def has_empty_modules_share?
      return false unless profession?

      profession_modules.where(finance_share: nil).exists?
    end

    def available_for_unty?
      ::PartnerPrograms::University2035::ExternalCourses.new.find(self).present?
    end

    def use_official_document?
      document_certificate? || document_diploma?
    end

    def profession_access_state(student)
      AccessLog
        .in_profession
        .creating
        .find_by(access_state: access_states.where(user: student))
        &.initiator
    end

    def archipelago?
      PartnerPrograms::University2035::ExternalCourses.new.archipelago_programs_include?(id)
    end

    def digital_profession?
      PartnerPrograms::University2035::ExternalCourses.new.digital_professions_include?(program_family_id)
    end

    def b2b_type
      return program_type&.slug || type unless b2b_course_library?

      program_family.program_family_type&.alias
    end

    def related_to_course_library?
      professions.any?(&:b2b_course_library?)
    end

    def b2b_course_library?
      url == B2B_COURSE_LIBRARY_URL
    end

    def async_and_not_course_library?
      asynchronous? && !b2b_course_library?
    end

    def help_center?
      url.in?(HELP_CENTER_URLS)
    end

    private

    def lessons_locked_service(user)
      @lessons_locked_service ||= ::Programs::AvailableForUsersLessonsService.new(self, user)
    end

    def set_default_values
      self.curator_id ||= 0
      self.trajectory ||= "not"
      self.use_unofficial_document = true if use_unofficial_document.nil?
    end
  end
end
