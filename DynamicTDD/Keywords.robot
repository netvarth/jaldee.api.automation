***Settings***
Library           RequestsLibrary
Library           String
Variables           messagesapi.py
Variables           messagesbase.py
Variables           messageslicence.py
Variables           superadminmessagesapi.py 

*** Variables ***
&{headers}                Content-Type=application/json
&{headers1}		          Content-Type=multipart/form-data
${SUSERNAME}              admin.support@jaldee.com
${PASSWORD}               Jaldee12
${SPASSWORD}              Netvarth1
${test_mail}              test@jaldee.com
${Invalid_email}          inv.${test_mail}
${LOWER}                  abcdefghijklmnopqrstuvwxyz
${UPPER}                  ABCDEFGHIJKLMNOPQRSTUVWXYZ
${LETTERS}                abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ
# ${NUMBERS}                0123456789
${digits}                 0123456789
${merchantid}             6811180
@{wl_status}              checkedIn     arrived   started   prepaymentPending   cancelled    done   unrevertable   failed   blocked
@{waitlist_cancl_reasn}   closingSoon   tooFull   prePaymentPending   holiday   noshowup   blocked   QueueDisabled   self
@{waitlist_actions}       REPORT    STARTED    CANCEL   CHECK_IN    DONE
@{calc_mode}              ML    Fixed   NoCalc   Conventional
@{payment_modes}          cash  DC  CC  NB  PPI  Mock  UPI  self_pay
${pay_mode_selfpay}       self pay
@{businessStatus}         Proprietorship  Individual  Partnership  Privatelimited  PublicLimited  LLP  Trust  Societies
@{accounttype}            Current  Saving
@{Business_type}          BRANCH  INDEPENDENT_SP
@{gstpercentage}          5.0  12.0  18.0  28.0
@{notifytype}             none  pushMsg  email
@{bool}                   False  True
@{boolean}                false  true
@{status}                 ACTIVE   INACTIVE  CANCELLED  INCOMPLETE
${bType}                  Waitlist
@{calctype}               Percentage  Fixed
@{disctype}               Predefine   OnDemand
@{recurringtype}          Daily  Weekly  Monthly  MonthlyWeekly  Once
@{parkingType}            street  privatelot  valet  free   paid   none
@{purpose}                prePayment  billPayment  subscriptionLicenseInvoicePayment  verifyPayuPayment  verifyPaytmPayment  donation   financeInvoicePayment    salesOrderInvoice
@{paymentStatus}          NotPaid  PartiallyPaid  FullyPaid  Refund  PartiallyRefunded  Paid
@{billStatus}             New  Settled  Cancel
@{billViewStatus}         Show  Notshow
@{businessFilingStatus}   Proprietorship  Individual  Partnership  Privatelimited  PublicLimited  LLP  Trust  Societies
@{Views}                  self  all  customersOnly
@{licenseType}            New   Downgrade   Upgrade   Renew   InvoiceGeneration   ChangeSubscritpion   InvoiceUpdate
@{Qstate}                 ENABLED  DISABLED  EXPIRED
@{verifyLevel}            NONE   BASIC   BASIC_PLUS   ADVANCED
@{discountType}			  AMOUNT  PERCENTAGE
@{age_group}			  CHILDREN    STUDENT  SENIORCITIZENS
@{statusboard_type}       SERVICE  QUEUE  DEPARTMENT
@{cupnpaymentStatus}      SUCCESS  REQUESTED  PAID  PAYMENTPENDING  INCOMPLETE   PENDING  PARTIALLYPAID
@{acceptPaymentBy}		  cash  other   self_pay
@{couponState}			  NEW  ENABLED  EXPIRED  DISABLED  DISABLED_BY_JALDEE  DISABLED_PROVIDER_LIMIT_REACHED
@{Reimburse_invoice}	  CASH	CHEQUE  INDISPUTE  NOTPAID
@{jaldee_reimburse_for}	  JBANK  JC  JCASH  TOTAL  
@{jaldeePaymentmode}      CASH	CHEQUE
@{couponStatus}			  DRAFT  ACTIVE  CANCELLED  DISABLE  EXPIRED 
# @{Genderlist}             female  male  others
@{Genderlist}             female  male
@{SystemNote}             SELF_PAY_REQUIRED  NO_OTHER_COUPONS_ALLOWED  COUPON_APPLIED  CANT_COMBINE_WITH_OTHER_COUPONES  COUPON_EXPIRED_OR_PASSIVE  ONLINE_CHECKIN_REQUIRED  ONLY_WHEN_FITST_CHECKIN  ONLY_WHEN_FITST_CHECKIN_ON_PROVIDER  MINIMUM_BILL_AMT_REQUIRED  EXCEEDS_APPLY_LIMIT
@{jdn_disc_percentage}    5.0  10.0   20.0
@{jdn_disc_max}           100   200   300
@{jdn_type}               Percent  Label
@{action}                 addService  adjustService  removeService  addItem   adjustItem   removeItem   addServiceLevelDiscount   removeServiceLevelDiscount   addItemLevelDiscount   removeItemLevelDiscount   addBillLevelDiscount   removeBillLevelDiscount   addProviderCoupons   removeProviderCoupons  addJaldeeCoupons   removeJaldeeCoupons   addDisplayNotes   addPrivateNotes  updateDeliveryCharges
@{NotificationResourceType}  TOKEN  APPOINTMENT  ACCOUNT   DONATION   ORDER
@{EventType}                WAITLISTADD  WAITLISTCANCEL  WAITLISTDONE  WAITLISTARRIVED  EARLY  PREFINAL  FINAL  APPOINTMENTADD  APPOINTMENTCANCEL  LICENSE  DONATIONSERVICE  
                            ...   FIRSTNOTIFICATION  SECONDNOTIFICATION  THIRDNOTIFICATION  FORTHNOTIFICATION  APPOINTMENTRESCHEDULE  ORDERCONFIRM  ORDERCANCEL  ORDERSTATUSCHANGE
@{travelMode}               DRIVING  WALKING  BICYCLING  TRANSIT  UNKNOWN
@{startTimeMode}            ONEHOUR   TWOHOUR   AFTERSTART
@{unit}                     METER  KILOMETER  MILE
@{Sctype}                   NATIONAL   JALDEE  EMPLOYEE_REF  REGIONAL     
@{bonusPeriod}              CAL_QUARTER   CAL_YEAR   NONE
@{kyc}                      CLEARED   IN_PROGRESS   NOT_CLEARED 
@{billCycle}                ANNUAL  MONTHLY
@{userType}                 PROVIDER  ASSISTANT  ADMIN  CONSUMER  SUPPORT  MANAGER  MARKETING  SUPERADMIN  PROVIDER_CONSUMER  PARTNER_USER
@{HowDoYouHear}             Jaldee  Facebook  Friend  GoogleSearch  SalesReps  Twitter  Other 
@{toggle}                   Enable  Disable
@{customerseries}           AUTO  MANUAL  PATTERN
# @{service_type}             donationService   virtualService   physicalService   billingService
@{ServiceType}              virtualService  physicalService  donationService  billingService  serviceRequest
@{multiples}                10  20  30  40  50
@{vservicetype}             audioService   videoService
@{CallingModes}             Zoom   WhatsApp   Phone   GoogleMeet  VideoCall
@{apptStatus}               prepaymentPending  Confirmed  Arrived  Started  Cancelled  Rejected  Completed  failed  calling  blocked  Rescheduled  Requested  RequestRejected
@{cancelReason}             noshowup  blocked  closingSoon  tooFull  self  prePaymentPending  QueueDisabled  holiday
@{waitlistedby}             CONSUMER  PROVIDER
@{waitlistMode}             WALK_IN_CHECKIN   ONLINE_CHECKIN   PHONE_CHECKIN   WHATSAPP_CHECKIN  TELEGRAM_CHECKIN
@{appointmentMode}          WALK_IN_APPOINTMENT  PHONE_IN_APPOINTMENT  ONLINE_APPOINTMENT   TELEGRAM_APPOINTMENT
@{reason}                   Holiday  QueueFull  ScheduleFull
@{Report_Types}             TOKEN   APPOINTMENT   DONATION   PAYMENT  ORDER
@{Report_Date_Category}     LAST_WEEK  NEXT_WEEK  LAST_THIRTY_DAYS  NEXT_THIRTY_DAYS  TODAY  YEARLY  DATE_RANGE  NONE
@{Report_Date_filter}       Last 7 days  Next 7 days  Last 30 days  Next 30 days  Today  Date Range
@{Payment_Purpose}          prePayment  billPayment  donation  subscriptionLicenseInvoicePayment  verifyPayuPayment  verifyPaytmPayment  verifyRazorpayPayment
@{Payment_Mode}             Mock  JCASH
@{Payment_Statuses}         SUCCESS   FAILED   INCOMPLETE   VOID
@{Transaction_type}         Waitlist    Appointment    Order    License    Donation 
@{ReportResponseType}       INLINE
@{Report_Status}            SEEN  DONE 
@{Checkin_mode}             Online   Walk in
@{apptBy}                   PROVIDER   CONSUMER
@{bookingType}              TOKEN  APPT  FOLLOWUP  ORDER
@{consultationMode}         EMAIL  PHONE  VIDEO   OP
@{consultationMode_verify}  Email  Phone  Video  Out Patient
@{donation_status}          PROCESSING   SUCCESS   FAILURE 
@{promotionalPriceType}     NONE   FIXED   PCT
@{promotionLabelType}       NONE   CLEARANCE   ONSALE   CUSTOM
@{promoLabelType}           None   Clearance   On Sale  Custom
@{orderStatuses}            Order Received   Order Acknowledged  Order Confirmed   Preparing   Packing   Payment Required   Ready For Pickup   Ready For Shipment   Ready For Delivery   Completed   In Transit   Shipped   Cancelled
@{AdvancedPaymentType}      NONE   FIXED   FULLAMOUNT
@{OrderTypes}               SHOPPINGCART    SHOPPINGLIST
@{ModeOfDelivery}           Home Delivery    Store Pickup
@{catalogStatus}            ACTIVE   INACTIVE
@{order_mode}               WALKIN_ORDER   ONLINE_ORDER  PHONE_ORDER
@{msg_type}                 order    donation
@{mraction}                 Medical record created    Prescription created    Clinical notes created    Medical record updated   Prescription updated   Clinical notes updated   Prescription uploaded   Clinical notes uploaded   Prescription shared   Clinical notes shared   Medical record shared  Prescription removed
${bookinglink}              <a href='http://localhost:8080/jaldee/status/{}' target='_blank' class='link'>{}</a>
@{delayType}                delayed   delay reduced
@{countryCodes}             +91   91  48  22  38
@{orderInternalStatus}      SUCCESS   PREPAYMENTPENDING    FAILED
@{grpstatus}                ENABLE  DISABLE
@{paymentStatusReport}      Not paid  Partially paid  Fully paid  Refund
@{wlStatusReport}           Checked In
@{bookingChannel}           WALK_IN  ONLINE  PHONE_IN  WHATSAPP  TELEGRAM
@{couponBasedOn}            ServiceBased  CatalogueBased
@{ValueType}                FIXED
@{JCstatus}                 ENABLED  DISABLED
@{JCwhen}                   APP_SIGNUP   ONLINE_BOOKING   ONLINE_ORDER   ONLINE_PAYMENT   TELE_HEALTH_CONSULTATION   ISSUED_BY_SA
@{JCscope}                  ALL_SPS   SP   SP_BY_LABEL   DOMAIN   SUB_DOMAIN   CONSUMER
@{JCtype}                   JALDEE_CASH  STORE_CREDIT
@{QnrDatatypes}             plainText  list  bool  date  number  fileUpload  map  dataGrid  dataGridList
@{QnrProperty}              plainTextPropertie   listPropertie  booleanProperties   dateProperties  numberPropertie   filePropertie  dataGridProperties  
@{QnrTransactionType}       DONATION  PAYMENT  ITEM  SERVICE  CONSUMERCREATION  DEPARTMENT  QUEUE  SCHEDULE  ORDER  LEAD  LEADSTATUS  IVR  MEMBERSHIPSERVICE
@{QnrChannel}               WALKIN  ONLINE  PHONEIN  ANY
@{QnrfileTypes}             png  jpg  doc  pdf  jpeg  bmp
@{QnrwhoCanAnswer}          CONSUMER_ONLY  PROVIDER_ONLY  BOTH_CONSUMER_AND_PROVIDER
@{QnrcaptureTime}           BEFORE  DURING  AFTER
@{messageType}              CHAT  ENQUIRY  ALERT  BOOKINGS
@{dateCategory}             TODAY  LAST_WEEK  TOTAL
@{statType}                 AWARDED  EXPIRED  EXPIRING  REDEEMED  REFUNDED
@{FileAction}               add  update  remove  noChange
@{QnrStatus}                INCOMPLETE  COMPLETE
@{QnrFieldScope}            consumer  service  visit
@{QnrReleaseStatus}         submitted  released  unReleased
@{itemType}                 PHYSICAL  VIRTUAL
# @{QnrId}                    Loan Sanction   Login Verified   Home Loan   credit verification 
@{MaritalStatus}            Single  Married  Widowed  Divorced  Separated
@{LoanAction}               add  remove  noChange  update
@{EmploymentStatus}         Salaried  SelfEmployed  Retired  Military  Homemaker  Student
@{NomineeType}              Father  Husband  Mother  Son  Daughter  Wife  Brother  MotherInlaw  FatherInlaw  DaughterInlaw  SisterInLaw  SonInlaw  BrotherInlaw  Other
@{parentSize}               Small   Medium   Large
@{partnerTrade}             Wholesale   Retail
@{CrmSchemeType}            Weekly  Monthly  Quarterly  HalfYearly  Yearly
@{reportType}               TOKEN  APPOINTMENT  ORDER  DONATION  PAYMENT  USER_REPORT  SUB_SERVICE_REPORT
 
@{analyticsFrequency}       DAILY  HOURLY  MONTHLY  YEARLY  NONE
@{invoicebooking}                  appointment  waitlist  orders  
&{tokenAnalyticsMetrics}    PHONE_TOKEN=1  WALK_IN_TOKEN=2  ONLINE_TOKEN=3  TELE_SERVICE_TOKEN=4  TELEGRAM_TOKEN=5
...  TOTAL_FOR_TOKEN=6  CHECKED_IN_TOKEN=7  ARRIVED_TOKEN=8  STARTED_TOKEN=9  CANCELLED_TOKEN=10  DONE_TOKEN=11
...  RESCHEDULED_TOKEN=12  TOTAL_ON_TOKEN=13  WEB_TOKENS=14  IOS_TOKENS=15  TOKENS_FOR_LICENSE_BILLING=20  ANDROID_TOKENS=16
...  QR_CODE_TOKENS=18  JALDEE_LINK_TOKENS=19  BRAND_NEW_TOKENS=94  JALDEE_CHANNEL_TOKENS=88

&{appointmentAnalyticsMetrics}  PHONE_APPMT=21  WALK_IN_APPMT=22  ONLINE_APPMT=23  TELE_SERVICE_APPMT=24  TELEGRAM_APPMT=25
...  CONFIRMED_APPMT=26  ARRIVED_APPMT=27  STARTED_APPMT=28  CANCELLED_APPMT=29  COMPLETETED_APPMT=30  
...  RESCHEDULED_APPMT=31  TOTAL_FOR_APPMT=32	TOTAL_ON_APPMT=33  WEB_APPMTS=34  IOS_APPMT=35  ANDROID_APPMTS=36
...  JALDEE_LINK_APPMT=39  APPMT_FOR_LICENSE_BILLING=75  BRAND_NEW_APPTS=95  JALDEE_CHANNEL_APPTS=89  REJECTED_APPMT=153

&{paymentAnalyticsMetrics}  PRE_PAYMENT_COUNT=44  PRE_PAYMENT_TOTAL=45  BILL_PAYMENT_COUNT=46  BILL_PAYMENT_TOTAL=47
...  ORDER_PRE_PAYMENT_COUNT=84  ORDER_PRE_PAYMENT_TOTAL=85  ORDER_BILL_PAYMENT_COUNT=86  ORDER_BILL_PAYMENT_TOTAL=87  
...  TOKEN_PRE_PAYMENT_COUNT=76  TOKEN_PRE_PAYMENT_TOTAL=77  TOKEN_BILL_PAYMENT_COUNT=78  TOKEN_BILL_PAYMENT_TOTAL=79
...  APPT_PRE_PAYMENT_COUNT=80  APPT_PRE_PAYMENT_TOTAL=81  APPT_BILL_PAYMENT_COUNT=82  APPT_BILL_PAYMENT_TOTAL=83

&{orderAnalyticsMetrics}  PHONE_IN_ORDER=40  WALK_IN_ORDER=41  ONLINE_ORDER=42  TOTAL_ORDER=43
...  RECEIVED_ORDER=56  ACKNOWLEDGED_ORDER=57  CONFIRMED_ORDER=58  PREPARING_ORDER=59  PACKING_ORDER=60
...  READY_FOR_PICKUP_ORDER=61  READY_FOR_SHIPMENT_ORDER=62  READY_FOR_DELIVERY_ORDER=63  COMPLETED_ORDER=63
...  IN_TRANSIT_ORDER=64  SHIPPED_ORDER=65  PAYMENT_REQUIRED_ORDER=66  CANCEL_ORDER=67  IOS_ORDER=68
...  ANDROID_ORDER=69  JALDEE_LINK_ORDER=70  QR_CODE_ORDER=71  TOTAL_ON_ORDER=72  WEB_ORDER=73  ORDERS_FOR_BILLING=74
...  BRAND_NEW_ORDERS=96

&{donationAnalyticsMetrics}  DONATION_COUNT=48  DONATION_TOTAL=49  

&{consumerAnalyticsMetrics}   WEB_NEW_CONSUMER_COUNT=50  TELEGRAM_NEW_CONSUMER_COUNT=51  IOS_NEW_CONSUMER_COUNT=52  
...  NEW_CONSUMER_TOTAL=54  TOTAL_BRAND_NEW_TRANSACTIONS=55  ANDROID_NEW_CONSUMER_COUNT=53

&{SearchViewAnalyticsMetrics}  JALDEE_WEB_SEARCH_COUNT=100  JALDEE_IOS_APP_SEARCH_COUNT=101  JALDEE_ANDROID_APP_SEARCH_COUNT=102  
...  JALDEE_WEB_BUS_PROFILE_VIEW_COUNT=103  JALDEE_IOS_APP_BUS_PROFILE_VIEW_COUNT=104  JALDEE_ANDROID_APP_BUS_PROFILE_VIEW_COUNT=105
...  SP_LINK_BUS_PROFILE_VIEW_COUNT=106

&{SPUserAnalyticsMetrics}   SP_USER_LOGIN_WEB_COUNT=107  SP_USER_LOGIN_IOS_COUNT=108  SP_USER_LOGIN_ANDROID_COUNT=109
&{ServiceWiseMetric}        TOTAL_FOR_TOKEN=6  TOTAL_ON_TOKEN=13  
&{DeptWiseMetric}        TOTAL_FOR_TOKEN=6  TOTAL_ON_TOKEN=13  


@{states}                   Kerala   Andhra Pradesh    Assam   Maharashtra   Nagaland     Arunachal Pradesh      Madhya Pradesh
@{telephoneType}    Residence    Company    Mobile    Permanent    Foreign    Other    Untagged

@{relationType}    Wife    Mother    Father    Husband    Son    Daughter    Brother    MotherInlaw    FatherInlaw    DaughterInlaw    SisterInLaw    SonInlaw    BrotherInlaw    Other
@{idTypes}    Passport    VoterID    UID    Other    RationCard    DrivingLicenseNo    Pan
@{idTypes_Name}    Passport    Voter ID    Aadhaar    Others    Ration Card    Driving License No    Pan
@{paymentprofileid}         spDefaultProfile   spDefaultBillProfile
@{displayName}              SP Default Payment Profile
@{chargeConsumer}           GatewayAPi
@{ownerType}                Provider  ProviderConsumer 
@{folderName}               privateFolder     publicFolder
@{sharedType}               secureShare   publicShare
@{context}                  communication   appointment   providerTask   prescription   jaldeeDrive   catalogCreation   itemCreation   order   waitlist  consumerTask   massCommunication   medicalRecord   serviceCreation   profileCreation   lead   enquiry  KYC   donation
@{advPayBankType}           JALDEE_BANK  SP_DEFAULT  SP_SPECIFIC_PROFILE  SERVICE_SPECIFIC
@{bankType}                 ProviderPaytm     JaldeeBank     NoBank     PrimaryBank
@{jsonNames}                businessProfile  virtualFields  terminologies  services  donationServices  location
@{catalogType}              submission  itemOrder
@{originFrom}               Lead   Enquire  LoanApplication  Loan  Task  NONE
@{serviceBookingType}       booking   request
@{rbac_feature}             cdl       booking      medicalrecord      adminSettings
@{rbac_capabilities}        createLoanApplication  updateLoanApplication  viewLoanApplication  verifyPartnerLoanApplication
...                         approveLoanApplication  createPartner  updatePartner  viewPartner  contactPartner  
...                         approvePartner  updatePartnerSettings  createLead  viewLead updateLead  invoiceUpdation  
...                         updateSalesOfficer  loanApplicationOperationsVerification  documentVerification actionRequired 
...                         rejectLoanApplication  viewCustomerPhoneNumber  createLocation  updateLocation  disablePartner
...                         enablePartner  createBranch  updateBranch  viewKycReport  
&{OtpPurpose}   ProviderSignUp=0  ConsumerSignUp=1  ProviderResetPassword=2  ConsumerResetPassword=3  ProviderVerifyEmail=4    
...             ConsumerVerifyEmail=5  VersionChange=6  AdminResetPassword=7  ManagerResetPassword=8  AssistantResetPassword=9  
...             AccountContactUpdate=10  SignIn=11  Authentication=12  ConsumerVerifyPhone=13  ProviderVerifyPhone=14  ConsumerAcceptance=15  
...             PartnerResetPassword=16  CoApplicantVerifyPhone=17  CoApplicantVerifyEmail=18  MultiFactorAuthentication=19  EquifaxScoreGenerate=20
...             CibilScoreGenerate=21  SPDataImport=22  CONSENT_FORM=23  ResetLoginId=24  LinkLogin=25

@{LoanApplicationStatus}            Active      Completed       Cancelled       Rejected    Inactive
@{custdeets}                        firstName  lastName  phoneNo  countryCode  gender  dob
@{LoanApplicationSpInternalStatus}  Draft  LoanRequest  ApprovalPending  ApprovalRequired  CreditApproved  SchemeConfirmed  BranchApproved  ConsumerAccepted  PartnerAccepted  Sanctioned  OperationsVerified
@{user}                             consumer  providerConsumer  provider  partner
@{file_action}                      add  remove
@{advancepaymenttype}               percentage  fixed
@{PartnerStatus}                    New    KYCApproved    CreditApproved    FinalApproved
@{PartnerInternalStatus}            Draft    ApprovalPending    Canceled    Approved    Rejected    Suspended
@{actiontype}                       ENABLE_CHANNEL   DISABLE_CHANNEL
@{ivr_actions}                      consumerVerfy  tokenVerfy  checkSchedule  generateToken  callUsers  language  getDepartment  setDepartment  getService  setService  addWaitlist  getWaitingTime  updateWaitingTime  getlanguage  removeToken
@{ivr_callpriority}                 High  Required  low
@{ivr_language}                     English  Hindi  Telugu
@{ivr_inputValue}                   0  1  2  3  4  5  6  7  8  9
@{ivr_dial_string}                  ANSWER  NOANSWER  CANCEL
@{ivr_call_status}                  received  missed  transferred
@{Availability}                     Available   Unavailable
@{ivr_status}                       connected  missed 	voicemail  success 	transferred  inCall  callCompleted
@{ivr_category}                     MONTHLY  WEEKLY  DATE_RANGE
@{dentalState}                      TEMPORARY  PERMANENT  MIXED
@{CategoryName}                     Booking
@{categoryType}                     Vendor  Expense  PaymentsInOut  Invoice
@{MembershipApprovalType}           Manual  Automatic
@{MembershipServiceStatus}          Enabled  Disabled
@{emptylist}
@{MemberApprovalStatus}             Hold  Approved  Inactive  Passed  Rejected
@{finance_payment_modes}            Cash   CC    EMI    Offline    PAYLATER    Mock    UPI    Other    NB    STORE_CREDIT    WALLET    JCASH    DC    PayLater    PAYTM_PostPaid    BANK_TRANSFER
@{CDLRelationType}                  CareOf  DaughterOf  SonOf  HusbandOf  WifeOf
@{CDLTypeCibil}                     cibil
@{toothType}                        ADULT  CHILD
@{toothSurfaces}                    BUCCAL   LINGUAL  PALATAL
@{PRStatus}                         OPEN  CLOSED  COMPLETED  ARCHIVE
@{RateType}                         Diminishing  Flat
@{WorkStatus}                       OPEN  CANCELED  COMPLETE
@{subcategory}                      ADD_PAYMENT_IN(AuditCategory.PAYMENT)   UPDATE_PAYMENT_IN(AuditCategory.PAYMENT)   UPDATE_PAYMENT_IN_STATUS(AuditCategory.PAYMENT)     ADD_PAYMENT_OUT(AuditCategory.PAYMENT)      UPDATE_PAYMENT_OUT(AuditCategory.PAYMENT)   UPDATE_PAYMENT_OUT_STATUS(AuditCategory.PAYMENT)      ADD_FINANCE_INVOICE(AuditCategory.FINANCE_INVOICE)    UPDATE_FINANCE_INVOICE(AuditCategory.FINANCE_INVOICE)        UPDATE_FINANCE_INVOICE_STATUS(AuditCategory.FINANCE_INVOICE)      ADD_EXPENSE(AuditCategory.EXPENSE)    UPDATE_EXPENSE(AuditCategory.EXPENSE)    UPDATE_EXPENSE_STATUS(AuditCategory.EXPENSE)
@{paymentGateway}                   PAYTM  PAYUMONEY  RAZORPAY
@{leadchannel}                      DIRECT  WHATSAPP  TELEGRAM  IVR  BRANDEDAPP
@{styleconfig}                      DashboardStyleConfig   UsersStyleConfig   FinanceStyleConfig
@{migrationType}                    Patients   Appointments  Notes
@{printTemplateStatus}              active   inactive
@{printTemplateType}                Prescription    Case    Finance
@{storeNature}                      PHARMACY   LAB    RADIOLOGY   WAREHOUSE  BAKERY  OTHERS
@{taxtypeenum}                      GST  CESS  VAT
@{customertitle}                    Mr.  Ms.  Mrs.  Master.
@{InventoryCatalogStatus}           Active   Inactive
@{transactionTypeEnum}              OPENING  ADJUSTMENT  PURCHASE_ORDER  PURCHASE  PURCHASE_RETURN	SALES_ORDER  SALES_ORDER_CANCEL  SALES  SALES_RETURN  TRANSFER_IN  TRANSFER_OUT
@{PurchaseStatus}                   DRAFT  IN_REVIEW  APPROVED
@{InvStatus}                        DRAFT  SUBMITTED  PROCESSED
@{orderStatus}                      ORDER_DRAFT        ORDER_CONFIRMED      ORDER_COMPLETED     ORDER_CANCELED      ORDER_DISCARDED
@{deliveryStatus}                   NOT_DELIVERED        ORDER_RECEIVED    PACKING    READY_FOR_PICKUP      IN_TRANSIST      DELIVERED 
@{locationType}                     googleMap  automatic  manual
@{prescriptionSharedStatus}         shared  notShared
@{serviceCategory}                  SubService   MainService
@{updateType}                       ADD  SUBTRACT
@{pushedStatus}                     PUSHED   ACCEPTED   DECLINED
@{status1}                          New     Pending    Assigned     Approved    Rejected
@{New_status}                       Proceed     Unassign    Block     Delete    Remove
@{deliveryType}                     STORE_PICKUP        HOME_DELIVERY    COURIER_SERVICE
@{spItemSource}                     RX       Ayur
@{VariableValueType}                String  Number  Decimal  Date  Link  File
@{VarStatus}                        Enabled  Disabled
@{VariableContext}                  CHECKIN  APPOINTMENT  DONATION  ACCOUNT  ORDER  COMMUNICATION  TASK  LOGIN  MEMBERSHIP  DEALER  LOAN_APPLICATION  CLOUD_ADMIN
@{InventoryAuditType}               PURCHASE        STOCK_ADJUST        INV_CATALOG        REMARK
@{InventoryAuditContext}            PURCHASE        INVENTORY        ITEM        CATALOG
@{InventoryAuditLogAction}          ADD             UPDATE             REMOVE             UPDATE_STATUS
@{templateFormat}                   PlainText
@{CommChannel}                      SMS  Whatsapp  Email  Telegram  App
@{CommTarget}                    	SPConsumer  SPUser  SPAdminUser
@{toothConditions}                    ABRASION_TOOTH   ATTRITION_TOOTH   FRACTURE_TOOTH    IMPACTED_TOOTH       MISSING_TOOTH     MOBILE_TOOTH    ROOT_STUMP_TOOTH
@{toothRestorations}                BRIDGE_TOOTH     CROWN_TOOTH     EXTRACTED_TOOTH
@{productEnum}                      APPOINTMENT     CHECKIN     ORDER    IVR
@{stockTransfer}                    DRAFT   DISPATCHED   RECEIVED   DECLINED   CANCELED
@{toggleButton}                     enable  disable
@{losProduct}                       CDL  PROPERTYLOAN  DOCTORSLOAN  TEACHERSLOAN
@{stageType}                        NEW  FOLLOWUP  KYC  KYCVERIFICATION  SALESFIELD  CREDITSCORE

*** Keywords ***


###### All Current Keywords above this line #############################################


Login
    [Arguments]    ${usname}  ${passwrd}  &{kwargs}
    ${login}=    Create Dictionary    loginId=${usname}  password=${passwrd}
    Set To Dictionary 	${login}  &{kwargs}
    ${log}=    json.dumps    ${login}
    Create Session    ynw    ${BASE_URL}  headers=${headers}  verify=true
    RETURN  ${log}

Check And Create YNW Session
    # ${res}=     Run Keyword And Return Status   GET On Session    ynw    /
    ${res}=   Session Exists    ynw
    # Run Keyword Unless  ${res}   Create Session    ynw    ${BASE_URL}  headers=${headers}
    IF  not ${res}
        Create Session    ynw    ${BASE_URL}  headers=${headers}  verify=true
    END

Create And Verify Alert
    [Arguments]    ${source_id_input}  ${category_id_input}   ${subcategory_id_input}  ${severity_id_input}    ${text_input}    ${subject_input}
    ${resp_post}=  Create Alert  ${source_id_input}  ${category_id_input}   ${subcategory_id_input}  ${severity_id_input}    ${text_input}    ${subject_input}
    Should Be Equal As Strings    ${resp_post.status_code}    200
    ${resp_get}=    GET On Session    ynw    provider/alerts/${resp_post.json()}   expected_status=any
    Should Be Equal As Strings    ${resp_get.status_code}    200
    Check Deprication  ${resp_get}  Create And Verify Alert
    RETURN    ${resp_get}

Verify Response
    [Arguments]  ${resp}  &{kwargs}
    ${items}=  Get Dictionary items  ${kwargs}
    FOR  ${key}  ${value}  IN  @{items}
        Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['${key}']}  ${value}
    END


Verify Response List
    [Arguments]  ${resp}  ${no}   &{kwargs}
    ${items}=  Get Dictionary items  ${kwargs}
    FOR  ${key}  ${value}  IN  @{items}
        Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[${no}]['${key}']}  ${value}
    END

Verify Response CloudSearch
    [Arguments]  ${resp}   &{kwargs}
    ${items}=  Get Dictionary items  ${kwargs}
    FOR  ${key}  ${value}  IN  @{items}
        Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['${key}']}  ${value}
    END

Cloud Search
    [Arguments]    &{kwargs}
    Create Session  cs  ${SEARCH_END}  verify=True
    ${resp}=    GET On Session  cs  /2013-01-01/search   params=${kwargs}   expected_status=any
    RETURN    ${resp}

    
Convert To twodigitfloat
    [Arguments]  ${value}
    ${value_float}=  twodigitfloat  ${value}
    ${value_float}=  Evaluate  ${value_float} * 1
    RETURN  ${value_float}


Get Random Valid Phone Number
    
    # FOR    ${index}    IN RANGE    10
    #     Log    ${index}
    #     ${PO_Number}=  random_phone_num_generator
    #     Log  ${PO_Number}
    #     ${count}=  count_digits  ${PO_Number.national_number}
    #     IF    ${count} < 10
    #         ${PO_Number}=  random_phone_num_generator
    #         Log  ${PO_Number}
    #         ${count}=  count_digits  ${PO_Number.national_number}
    #     ELSE
    #         Return From Keyword  ${PO_Number}
    #     END
    # END
    ${countryCode}  ${Number}=  random_phone_num_generator
    Append To File  ${EXECDIR}/data/TDD_Logs/proconnum.txt  ${SUITE NAME} - ${TEST NAME} - ${Number}${\n}
    RETURN  ${countryCode}  ${Number}

Generate Random Phone Number
    
    FOR    ${index}    IN RANGE    10
        ${PH_Number}    Generate random string    10    [NUMBERS]
        ${PH_Number}    Convert To Integer  ${PH_Number}
        ${count}=  count_digits  ${PH_Number}
        IF    ${count} < 10
            ${PH_Number}=  Generate random string    10    [NUMBERS]
            Log  ${PH_Number}
            ${count}=  count_digits  ${PH_Number}
        ELSE
            Return From Keyword  ${PH_Number}
        END
    END
    Append To File  ${EXECDIR}/data/TDD_Logs/proconnum.txt  ${SUITE NAME} - ${TEST NAME} - ${PH_Number}${\n}



Generate Random 555 Number
    ${PH_Number}    Random Number 	       digits=5 
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    ${Phone}=   Set Variable  555${PH_Number}
    Append To File  ${EXECDIR}/data/TDD_Logs/proconnum.txt  ${SUITE NAME} - ${TEST NAME} - ${Phone}${\n}
    RETURN  ${Phone}
    

Generate Random Test Phone Number
    [Arguments]    ${baseNumber}
    ${PH_Number}    Random Number 	       digits=7
    # ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    ${Phone}=  Evaluate  ${baseNumber}+${PH_Number}
    Append To File  ${EXECDIR}/data/TDD_Logs/proconnum.txt  ${SUITE NAME} - ${TEST NAME} - ${Phone}${\n}
    RETURN  ${Phone}

Check Deprication
    [Arguments]    ${response}  ${keyword_name}
    IF  'Deprecated-Url' in &{response.headers}
        Log  ${response.headers['Deprecated-Url']}
        Log  *${keyword_name} DEPRECATED in REST.*  level=WARN
    END


# Set TZ Header
#     [Arguments]  &{kwargs}
#     ${tzheaders}=    Create Dictionary  
#     ${locparam}=    Create Dictionary 
#     Log  ${kwargs}
#     ${x} =    Get Variable Value    ${kwargs}  
#     IF  ${x}=={} or '${kwargs.get("timeZone")}'=='${None}' or '${kwargs.get("location")}'=='${None}'
#         Set To Dictionary 	${tzheaders} 	timeZone=Asia/Kolkata
#         Log  ${tzheaders}
#     ELSE
#         FOR    ${key}    ${value}    IN    &{kwargs}
#             IF  "${key}".lower()=="timezone"
#                 Set To Dictionary 	${tzheaders} 	timeZone=${value}
#                 Remove From Dictionary 	&{kwargs} 	${key}
#                 Log  ${tzheaders}
#             ELSE IF  '${key}' == 'location'
#                 Set To Dictionary 	${locparam}   ${key}=${value}
#                 Remove From Dictionary 	&{kwargs} 	${key}
#                 Log  ${locparam}
#             END
#         END
#     END
#     # Log  ${params}
#     # Log  ${cons_headers}
#     Log  ${kwargs}
#     RETURN  ${tzheaders}  ${kwargs}  ${locparam}
    

Get Cookie from Header
    [Arguments]    ${response}
    IF  'Set-Cookie' in &{response.headers}
        Log  ${response.headers['Set-Cookie']}
        ${Sesioncookie}    ${rest}    Split String    ${response.headers['Set-Cookie']}    ;  1
        ${cookie_parts}    ${jsessionynw_value}    Split String    ${Sesioncookie}    =
        Log   ${jsessionynw_value}
    ELSE IF  'Cookie' in &{response.request.headers}
        Log  ${response.request.headers['Cookie']}
        ${cookie_parts}    ${jsessionynw_value}    Split String    ${response.request.headers['Cookie']}    =
        Log   ${jsessionynw_value}
    END
    RETURN    ${jsessionynw_value}

    
Get service names
    [Arguments]    ${response}  ${service_names}
    # ${resp}=   Get Service
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${response}
    ${names}=  Evaluate  [item['name'] for item in ${response}]
    Log  ${names}
    Append To List  ${service_names}  @{names}
    RETURN  ${service_names}

    