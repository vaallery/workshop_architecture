require "snils/rails"

module Legacy
  class User < ApplicationRecord
    class SubscriptionSettings
      BASE_SETTINGS = {
        deadlines: false,
        digest: false,
        events: false,
        marketing_communications: false,
        sms: false,
        technical_notifications: false,
        telegram_free_lessons: false
      }.freeze

      LIST_KEYS = {
        deadlines: "d",
        digest: "s",
        events: "2",
        marketing_communications: "n",
        sms: "sms",
        technical_notifications: "e",
        telegram_free_lessons: "t"
      }.freeze

      INV_LIST_KEYS = LIST_KEYS.invert.freeze

      attr_reader :values

      # @param subscribe_lists String | Hash(Symbol, true | false)
      def initialize(subscribe_lists)
        @values =
          if subscribe_lists.blank?
            BASE_SETTINGS.dup
          else
            case subscribe_lists
            when String
              settings = INV_LIST_KEYS.slice(*subscribe_lists.split(",")).invert
              BASE_SETTINGS.to_h { |key, value| [key, settings[key] ? true : value] }
            when Hash
              settings = subscribe_lists.symbolize_keys
              BASE_SETTINGS.to_h { |key, value| [key, settings[key] || value] }
            else
              raise ArgumentError, "subscribe_lists is #{subscribe_lists.class.name}"
            end
          end
      end

      def to_s
        values.filter_map { |key, val| val && LIST_KEYS[key] }.join(",")
      end

      LIST_KEYS.each_key do |key|
        define_method(key) { values[key] }
        define_method("#{key}=") { |new_value| values[key] = new_value }
      end
    end

    EMAIL_VALIDATION_REGEXP = /\A[a-zA-Z0-9_.+\-]*@[a-zA-Z0-9\-]+\.[a-zA-Z0-9\-.]+\z/
    NAME_VALIDATION_REGEXP = /\A[a-zа-яё][a-zа-яё\s-]+\z/i
    BIRTHDATE_VALIDATION_REGEXP = /\A\d{4}-\d{2}-\d{2}\z/
    FAKE_PHONE = "+7 (999)-999-99-99"
    SOCIAL_NETWORKS = [:vkontakte, :twitter, :linkedin].freeze
    AUTOLOGIN_PARAMETER_NAME = :authkey
    DEFAULT_REG_PLACE = "other".freeze

    TAX_TYPE_CIVIL_CONTRACT = "civil_contract"
    TAX_TYPE_CIVIL_CONTRACT_13 = "civil_contract_13"
    TAX_TYPE_CIVIL_CONTRACT_NO_RESIDENT = "civil_contract_no_resident"
    TAX_TYPE_SOLAR_STAFF = "solar_staff"
    TAX_TYPE_SOLE_PROPRIETOR = "sole_proprietor"
    TAX_TYPE_FOREIGN = "foreign"
    TAX_TYPE_FOREIGN_RESIDENT = "foreign_resident"
    TAX_TYPE_LLC = "llc"
    TAX_TYPE_EMPLOYMENT_CONTRACT = "employment_contract"

    include AASM
    include PhpDeserialization
    include Authority::Abilities
    include TranslateEnum
    include HasSecretKeys
    include Traqtor::Trackable
    include AfterCommitEverywhere
    include Flipper::Identifier

    self.inheritance_column = :_type_disabled

    mount_uploader :avatar, ::UserAvatarUploader

    devise :database_authenticatable, :encryptable,
           :recoverable, :rememberable, :validatable, :trackable, :lockable

    # Т.к. в легаси базе пароль хранится не по рельсовым конвенциям
    # требуется подключить примесь
    include DeviseInterface

    php_deserialize :service_data

    enum type: {
      employee: 8, # сотрудник Нетологии (original const - TYPE_EMPLOYEE_REAL)
      expert: 3, # эксперт (original const - TYPE_EXPERT)
      student: 4, # студент (original const - TYPE_STUDENT)
      admin: 1, # админ (original const - TYPE_EMPLOYEE)

      ### Типы пользователей b2b направления. Добавил трехзначный код, чтобы избежать пересечений
      b2b_hr: 100 # HR компании-клиента
    }

    enum gender: {
      none: 0,
      man: 1,
      woman: 2
    }, _prefix: true

    enum source: {
      webinar: "webinar",
      distance_course: "distance-course",
      mini_course: "mini-course",
      tizer: "tizer",
      landing_video: "landing-video",
      unknown: "unknown",
      demo: "demo",
      blog_leadform: "blog-leadform",
      mobile: "mobile"
    }

    # NOTE: AASM for active below
    enum active: {
      inactive: 0,
      active: 1,
      pd_deleted: 2,
    }

    # https://github.com/activerecord-hackery/ransack/wiki/Using-Ransackers#4-convert-an-integer-database-field-to-a-string-in-order-to-be-able-to-use-a-cont-predicate-instead-of-the-usual-eq-which-works-out-of-the-box-with-integers-to-find-all-records-where-an-integer-field-id-in-this-example-contains-an-input-string
    ransacker :searchable_id do
      Arel.sql("CONVERT(#{table_name}.id, CHAR(8))")
    end

    def self.ransackable_attributes(auth_object = nil)
      %w[
        id
        searchable_id
        email
        snils
        type
        active
        name
        name1
        name2
        patronymic
        search_text
      ]
    end

    translate_enum :type
    translate_enum :gender

    belongs_to :address, optional: true, class_name: "Legacy::Address", foreign_key: :address_id
    belongs_to :certificates_address, optional: true, class_name: "Legacy::Address", foreign_key: :certificates_address_id
    belongs_to :nationality_country, optional: true, class_name: "Legacy::Country", foreign_key: :nationality_country_id
    belongs_to :delete_requestor, optional: true, class_name: "Legacy::User", foreign_key: :delete_requestor_id

    has_one :user_data, class_name: "Legacy::UserData"
    has_one :admin, dependent: :restrict_with_error
    has_one :legal_organization
    has_one :user_subscribes_settings_link, dependent: :destroy
    has_one :telebot_account, class_name: "TeleBot::UserToken", dependent: :nullify
    has_one :expert_attribute_collection, dependent: :destroy
    has_one :source_data, -> { where(type: "user") }, dependent: :delete, foreign_key: :sourceble_id
    has_one :employee_card, class_name: "OrgStructure::Employee", dependent: :destroy
    has_one :user_address, class_name: "Legacy::UserAddress", dependent: :destroy
    has_one :motivation_bot, class_name: "HelpDesk::UserMotivationBot", dependent: :destroy
    has_one :student_goals_objective, class_name: "StudentGoals::UserObjective", dependent: :destroy
    has_one :qna_user_notification_config, class_name: "QnA::UserNotificationConfig", dependent: :destroy
    has_one :main_phone, -> { main_phone }, class_name: "Legacy::UserPhone"
    has_one :coordinator_payouts_employee_contract, class_name: "Payouts::Coordinators::EmployeeContract"
    has_one :otp_config, class_name: "OTPConfig", dependent: :destroy, as: :configurable
    has_one :edutoria_user, class_name: "Edutoria::User"
    has_one :user_email_confirmation, class_name: "UserEmailConfirmation", dependent: :destroy

    has_many :cold_traffic_visitors, foreign_key: :user_id_unique, inverse_of: :user
    has_many :access_state, as: :last_creating_initiator, dependent: :restrict_with_error
    has_many :access_logs, as: :initiator, dependent: :restrict_with_error
    has_many :diploma_requests, class_name: "Legacy::DiplomaRequest", dependent: :nullify
    has_many :user_requests, class_name: "User::Request", dependent: :nullify
    has_many :decrees, class_name: "User::NetoDocument::Decree", dependent: :nullify
    has_many :expulsion_decrees, class_name: "User::NetoDocument::ExpulsionDecree", dependent: :nullify
    has_many :enrollment_decrees, class_name: "User::NetoDocument::EnrollmentDecree", dependent: :nullify

    has_many :user_lesson_statuses, class_name: "LMS::UserLessonStatus"
    has_many :user_lesson_item_statuses, class_name: "LMS::UserLessonItemStatus"

    has_many :product_assigned_coordinators, class_name: "HelpDesk::ProductAssignedCoordinator", dependent: :destroy
    has_many :access_states, dependent: :destroy
    has_many :access_levels, through: :access_states, source: :resource, source_type: "LMS::Programs::AccessLevel"
    has_many :oauth_access_grants, class_name: "Doorkeeper::AccessGrant", foreign_key: :resource_owner_id, dependent: :delete_all
    has_many :oauth_access_tokens, class_name: "Doorkeeper::AccessToken", foreign_key: :resource_owner_id, dependent: :delete_all
    has_many :promo_campaign, as: :owner, dependent: :destroy
    has_many :documents, class_name: "Legacy::UserDocument", dependent: :destroy
    has_many :orders, class_name: "Legacy::Order", dependent: :destroy
    has_many :manager_orders, class_name: "Legacy::Order", foreign_key: :manager_id, dependent: :destroy
    has_many :mc_programs, class_name: "Legacy::McProgram", foreign_key: :trainer_id
    has_many :subscriptions, class_name: "Subscriptions::Subscription", dependent: :delete_all
    has_many :user_phones, class_name: "Legacy::UserPhone", dependent: :destroy
    has_many :user_to_mini_courses, source: :program, through: :user_to_mc
    has_many :user_playlist, class_name: "Legacy::UserPlaylist"
    has_many :user_abonements, dependent: :destroy
    has_many :abonements, through: :user_abonements
    has_many :user_reviews, dependent: :destroy
    has_many :program_family_managers, dependent: :destroy, foreign_key: :manager_id
    has_many :program_families, through: :program_family_managers
    has_many :expert_paid_services, foreign_key: :expert_id
    has_many :paid_services, through: :expert_paid_services
    has_many :base_tariffs, class_name: "LMS::Experts::BaseTariff", dependent: :destroy, foreign_key: :expert_id
    has_many :product_base_tariffs, class_name: "LMS::Products::ExpertBaseTariff", dependent: :destroy, foreign_key: :expert_id
    has_many :user_tests, class_name: "LMS::Tests::UserTest", dependent: :destroy
    has_many :user_deadlines, class_name: "LMS::UserDeadline", dependent: :destroy
    has_many :task_homeworks, class_name: "LMS::Tasks::Homework", dependent: :destroy
    has_many :job_exam_homeworks, class_name: "LMS::JobExams::Homework", dependent: :destroy, foreign_key: :student_id
    has_many :expert_incomes, dependent: :restrict_with_error, foreign_key: :expert_id
    has_many :user_feedbacks, class_name: "LMS::UserFeedback", dependent: :destroy
    has_many :shared_diplomas, dependent: :destroy
    has_many :achievable_package_user_progresses, class_name: "LMS::Programs::AchievablePackageUserProgress", dependent: :destroy
    has_many :deadline_requests, class_name: "LMS::Tasks::DeadlineRequest", dependent: :delete_all
    has_many :deadline_notifications, class_name: "LMS::Tasks::DeadlineNotification", dependent: :delete_all
    has_many :offline_lecture_experts, class_name: "LMS::OfflineLectures::OfflineLectureExpert", foreign_key: :expert_id, dependent: :delete_all
    has_many :offline_lectures, through: :offline_lecture_experts
    has_many :webinar_experts, class_name: "LMS::Webinars::WebinarExpert", foreign_key: :expert_id, dependent: :delete_all
    has_many :webinars, through: :webinar_experts
    has_many :user_poll_results, class_name: "LMS::Polls::UserPollResult", dependent: :restrict_with_exception
    has_many :user_accepts, dependent: :destroy
    has_many :certificates, dependent: :destroy
    has_many :tickets, class_name: "HelpDesk::Ticket"
    has_many :as_curator_help_desk_tickets, class_name: "HelpDesk::Ticket", foreign_key: :curator_id, dependent: :nullify
    has_many :user_support_teams, class_name: "HelpDesk::UserSupportTeam", dependent: :destroy
    has_many :support_teams, through: :user_support_teams, class_name: "HelpDesk::SupportTeam"
    has_many :user_contacts, class_name: "Legacy::UserContact", dependent: :destroy
    has_many :expert_notes, class_name: "Legacy::ExpertNote", dependent: :destroy
    has_many :attachment_files, class_name: "Legacy::UserAttachmentFile", dependent: :destroy
    has_many :lead_informations, dependent: :destroy

    has_many :coordinator_incomes, class_name: "Payouts::Coordinators::CoordinatorIncome", foreign_key: :coordinator_id, dependent: :restrict_with_error
    has_many :coordinator_workloads, class_name: "Payouts::Coordinators::Workload", foreign_key: :coordinator_id, dependent: :restrict_with_error

    has_many :with_access_orders, -> { roots.with_access }, class_name: "Legacy::Order", dependent: :restrict_with_error
    has_many :accessible_programs, -> { distinct }, through: :with_access_orders, source: :program
    has_many :read_messages, class_name: "Notifications::ReadMessage", dependent: :delete_all
    has_many :social_nets, inverse_of: :user, dependent: :destroy
    has_many :webinar_registrations, class_name: "LMS::Webinars::UserRegistration", dependent: :restrict_with_error

    has_many :student_groups_memberships, class_name: "LMS::Students::GroupsUser", inverse_of: :groups_users
    has_many :student_groups, through: :student_groups_memberships, source: :group, inverse_of: :users

    has_many :push_notifications_tokens, class_name: "::Push::Token"
    has_many :json_storage, class_name: "::UserJsonStorage", dependent: :destroy
    has_many :installments
    has_many :study_periods, class_name: "LMS::Programs::StudyPeriod", dependent: :nullify
    has_many :lesson_user_views, class_name: "LMS::Programs::LessonUserView", dependent: :restrict_with_error

    has_many :experts_favorite_lesson_items, class_name: "LMS::Experts::FavoriteLessonItem", foreign_key: :expert_id, dependent: :delete_all
    has_many :expert_favorite_lesson_items, through: :experts_favorite_lesson_items, source: :lesson_item
    has_many :carts, foreign_key: :purchaser_id

    has_many :program_segmentations, class_name: "LMS::Programs::UserSegmentation", dependent: :restrict_with_error
    has_many :actual_program_segmentations, -> { actual }, class_name: "LMS::Programs::UserSegmentation", dependent: :restrict_with_error
    has_many :programs_user_terminations, class_name: "LMS::Programs::UserTermination", dependent: :nullify
    has_many :programs_passed_user_terminations, -> { passed }, class_name: "LMS::Programs::UserTermination", dependent: :nullify
    has_many :proftest_results, dependent: :destroy
    has_many :user_graduation_events, dependent: :destroy
    has_many :qna_questions, class_name: "QnA::Question", dependent: :restrict_with_error
    has_many :legal_agreements, dependent: :destroy
    has_many :diploma_issuances, dependent: :destroy
    has_many :edu_certificate_requests, dependent: :destroy, inverse_of: :user
    has_many :student_achievements, class_name: "LMS::Achievements::StudentAchievement", dependent: :restrict_with_error, inverse_of: :student, foreign_key: :student_id
    has_many :achievement_levels, through: :student_achievements, class_name: "LMS::Achievements::AchievementLevel"
    has_many :achievements, through: :student_achievements, class_name: "LMS::Achievements::Achievement"

    has_many :devices, class_name: "Mobile::Device", dependent: :destroy, inverse_of: :user
    has_many :notifications, class_name: "Mobile::Notification", dependent: :destroy, inverse_of: :recipient
    has_many :notification_settings, class_name: "NotificationSetting", dependent: :destroy

    has_many :notes, class_name: "LMS::Note", dependent: :restrict_with_error

    has_many :graph_node_to_users, dependent: :destroy
    has_many :graph_nodes, through: :graph_node_to_users, source: :graph_node
    has_many :recommendation_tags,
             -> { where(type: "RecommendationTags::Models::TagGraphNode") },
             through: :graph_node_to_users,
             source: :graph_node

    has_many :legacy_user_admin_roles, dependent: :destroy, class_name: "Legacy::UserAdminRole"
    has_many :legacy_admin_roles, through: :legacy_user_admin_roles, class_name: "Legacy::AdminRole", source: :admin_role

    has_and_belongs_to_many :tags, class_name: "Legacy::UserTag", join_table: "trainer_to_tag", association_foreign_key: :tag_id

    # B2B associations
    has_one :b2b_employee, dependent: :destroy, class_name: "B2B::Models::Employee"
    has_one :b2b_company, through: :b2b_employee, source: :b2b_company, class_name: "B2B::Models::Company"
    has_one :b2b_setting, through: :b2b_employee, class_name: "B2B::Models::Setting"
    has_many :b2b_group_issued_accesses, class_name: "B2B::Models::GroupIssuedAccess"

    has_many :coordinator_to_programs, class_name: "Legacy::CoordinatorToProgram", foreign_key: :coordinator
    has_many :coordinated_programs, through: :coordinator_to_programs, source: :program, class_name: "Legacy::Program"

    has_many :refund_requests
    has_many :retention_from_refunds
    has_many :user_learning_locks, class_name: "LMS::UserLearningLock", dependent: :delete_all

    scope :managers, -> { where(type: [:admin, :employee]) }
    scope :subscribed, -> { where(subscribed: true) }
    scope :students, -> { where(type: types[:student]) }

    scope :active, -> { where(active: :active) }
    scope :delete_requested, -> { where.not(delete_requested_at: nil) }
    scope :requested_deletion_older_than, ->(days) { where("delete_requested_at <= ?", days.days.ago) }

    # Сортировка по ФИО, с учетом того, что юзеры с пустыми ФИО должны быть последними в списке
    # Ах, если бы был POSTGRES, могли бы делать NULLS LAST и не знали бы горя
    scope :ordered_by_fio_with_nulls_last, -> do
      order(
        "ISNULL(name2)", "name2",
        "ISNULL(name1)", "name1",
        "ISNULL(patronymic)", "patronymic"
      )
    end

    accepts_nested_attributes_for :user_contacts, :user_address, :employee_card, :expert_notes, :attachment_files,
                                  :admin, :expert_attribute_collection, :coordinator_payouts_employee_contract,
                                  reject_if: :all_blank, allow_destroy: true

    before_validation :unconfirm_email, if: :will_save_change_to_email?
    before_save :fill_search_text

    validates :snils, snils: true

    # NOTE: enum for active above
    aasm column: "active", enum: true do
      state :active, initial: true, value: 1
      state :inactive, value: 0
      state :pd_deleted, value: 2

      event :deactivate do
        before do
          Rails.logger.tagged("User #{id}", "deactivate") do
            Rails.logger.info("Starting deactivation")
          end
        end

        transitions from: :active, to: :inactive

        after do
          Rails.logger.tagged("User #{id}", "deactivate") do
            Rails.logger.info("User has been deactivated")
          end
        end
      end

      event :mark_to_delete do
        before do
          Rails.logger.tagged("User #{id}", "mark_to_delete") do
            Rails.logger.info("Starting deactivation")
          end
        end

        transitions from: :active, to: :inactive, guard: :deactivatable?

        after do
          Rails.logger.tagged("User #{id}", "mark_to_delete") do
            update(delete_requested_at: Time.current) if delete_requested_at.blank?
            Rails.logger.info("User has been deactivated")
          end
        end
      end

      event :reactivate do
        transitions from: :inactive, to: :active

        before do
          Rails.logger.tagged("User #{id}", "reactivate") do
            Rails.logger.info("Starting reactivate")
          end
        end

        transitions from: :inactive, to: :active

        after do
          Rails.logger.tagged("User #{id}", "reactivate") do
            update(delete_requestor_id: nil, delete_requested_at: nil)
            Rails.logger.info("User has been reactivated")
          end
        end
      end

      event :mark_pd_deleted do
        transitions from: :inactive, to: :pd_deleted
      end
    end

    def initialize(attrs = nil)
      super
      self.auth_token_checksum = Auth::TokenChecksumService.regenerate_checksum if auth_token_checksum.nil?
    end

    # Переопределяем умолчание, т.к. в MySQL encrypted_password пишут в password колонку
    # Не можем вынести метод в модуль, т.к. подключается несколько модулей с таким методом
    def password
      read_attribute(:password)
    end

    def remember_me
      true
    end

    def has_crm_access?
      admin? || employee?
    end

    def has_new_crm_access?
      admin.present?
    end

    def frdo_ready?
      return false if birthdate.blank? || nationality_country.blank? || gender == "none"
      return false if birthdate >= 10.years.ago
      return true if nationality_country.oksm_code != Legacy::Country::RUS_OKSM_CODE

      snils.present?
    end

    def phone
      main_phone&.phone
    end

    def snils=(value)
      # Snils.new(nil) returns random snils value
      # To prevent it we directly write nil value
      write_attribute(:snils, value.present? ? Snils.new(value).raw : nil)
    end

    def avatar_url(image_type, with_domain: false)
      site_url = APP_CONFIG.hosts.netology
      no_photo_path = "/images2/nouser.jpg"

      if avatar?
        avatar_path(image_type)
      elsif service.present? && service_data[:imageUrl].present?
        service_data[:imageUrl]
      else
        "#{with_domain ? site_url : ''}#{no_photo_path}"
      end
    end

    def avatar_path(image_type)
      return "" unless avatar?

      case image_type
      when "source", "big"
        avatar.url
      when Integer, "main_page"
        ""
      else
        avatar.thumb.url
      end
    end

    def has_full_access?(program)
      access_to_mc? || have_access_to?(program)
    end

    # Есть ли открытый доступ к Библиотеке курсов
    def access_to_course_library?
      access_states.with_access.joins(:program).where(programs: { url: Legacy::Program::B2B_COURSE_LIBRARY_URL }).exists?
    end

    # Есть ли открытый доступ к старым мини-курсам
    def access_to_mc?
      access_states
        .with_access
        .joins(access_level: [program: [program_family: :program_family_type]])
        .where(program_family_types: { alias: "subscription-video-courses" })
        .exists?
    end

    def self.profile_owner?(user, current_user)
      return false unless user.present? && current_user.present?

      user.id == current_user.id
    end

    def can_show_profile_to_user?(other_user)
      id == other_user.id ||
        # Проверка для B2B (новая логика)
        (b2b_company.present? && b2b_company == other_user.b2b_company)
    end

    def mini_courses
      Users::UserMiniCoursesQuery.new(self).courses
    end

    def self.authorizer
      Legacy::UserAuthorizer
    end

    # TODO: access for program with webinar type is not calculated correctly
    def have_access_to?(edu_object)
      # Хак для проверки доступа к наборам Хелп-деска
      return true if edu_object.respond_to?(:help_center?) && edu_object.help_center?

      case edu_object
      when LMS::Lesson then !edu_object.locked_for?(self)
      when LMS::LessonItem then !edu_object.locked_for?(self)
      else access_control_list_service.fetch(edu_object)
      end
    end

    def access_control_list_service
      @access_control_list_service ||= Users::DefineAccessService.new(id)
    end

    def autologin_authkey
      Digest::MD5.hexdigest("#{email}#{password}#{Rails.application.secrets.authkey_salt}")
    end

    def self.from_omniauth(auth_data)
      joins(:social_nets).where(social_nets: auth_data.slice("provider", "uid")).first
    end

    def has_payment?
      @has_payment = Cart.where(purchaser_id: id).joins(:payment_transactions).merge(::PaymentTransaction.payment.succeeded).exists? || Legacy::Order.paid.where(user_id: id).exists? if @has_payment.nil?
      @has_payment
    end

    def has_admin_roles?
      admin? || employee? || expert?
    end

    def subscription_settings
      @subscription_settings ||= SubscriptionSettings.new(subscribe_lists)
    end

    def subscribe_lists=(v)
      @subscription_settings = nil
      super
    end

    def reload
      @subscription_settings = nil
      super
    end

    def fill_search_text
      self.search_text = [name1&.strip, name2&.strip, name1&.strip, patronymic&.strip, email].join(" ")[0..254]
    end

    def unconfirm_email
      self.is_confirmed_email = 0
    end

    def custom_password?
      # Могут быть значения true, false, nil
      add_data&.dig("password_custom") == true
    end

    def deactivatable?
      return true if student? && !paid_access?
      return b2b_company.b2b_employees.size < 2 if b2b_hr?

      false
    end

    def paid_access?
      carts_with_promocodes? || payment_transactions? || installments?
    end

    def carts_with_promocodes?
      carts.where.not(promo_code_id: nil).exists?
    end

    def payment_transactions?
      carts.joins(:payment_transactions)
        .where.not(payment_transactions: { state: "failed" })
        .distinct("carts.id")
        .exists?
    end

    def installments?
      installments.exists?
    end

    def unpaid_installments?
      installments.where("paid_amount < amount").exists?
    end

    def has_permission?(action, name)
      # => { directions: { read: true, change: true }, ... }
      @permissions ||=
        NewPermission.for_user(id)
          .pluck(:name, :action)
          .each_with_object({}) do |(name, action), acc|
            name = name.to_sym
            acc[name] ||= {}
            acc[name][action.to_sym] = true
          end

      @permissions.dig(name.to_sym, action.to_sym)
    end
  end
end
