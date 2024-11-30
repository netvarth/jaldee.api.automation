*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Run Keywords  Delete All Sessions
Force Tags        Membership Service
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           RequestsLibrary
Library           OperatingSystem
Library           /ebs/TDD/excelfuncs.py
Library		      /ebs/TDD/Imageupload.py
Resource          /ebs/TDD/SuperAdminKeywords.robot
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 
Variables         /ebs/TDD/varfiles/hl_providers.py

*** Variables ***
${LoginId}  5550097274
${PASSWORD}     Jaldee01
${maxBookings}  20
${var_file}     ${EXECDIR}/data/${ENVIRONMENT}_varfiles/providers.py
${data_file}    ${EXECDIR}/data/${ENVIRONMENT}data/${ENVIRONMENT}phnumbers.txt
${bprof_file}    ${EXECDIR}/data/${ENVIRONMENT}data/${ENVIRONMENT}bprofile.txt

*** Keywords ***
Remove Entry From File
    [Arguments]    ${bprof_file}    ${LoginId}
    ${content}=    Get File    ${bprof_file}
    ${lines}=    Split To Lines    ${content}
    ${filtered_lines}=    Evaluate    [line for line in ${lines} if not line.startswith('${LoginId}')]
    IF    len(${filtered_lines}) == 0
        Create File    ${bprof_file}    ''    
    ELSE
        Create File    ${bprof_file}
        FOR    ${line}    IN    @{filtered_lines}
            Append To File    ${bprof_file}    ${line}${\n}
        END
    END
    Log    Updated file content without lines starting with ${LoginId}

*** Test Cases ***
JD-TC-UpdateBProfile
    [Documentation]  Updating Business Profile, create custom id, location, service and schedule for  ${LoginId}

    ${firstname}  ${lastname}  ${PhoneNumber}  ${LoginId}=  Provider Signup without Profile
    ${num}=  find_last  ${var_file}
    ${num}=  Evaluate   ${num}+1
    Append To File  ${data_file}  ${LoginId} - ${PASSWORD}${\n}
    Append To File  ${var_file}  PUSERNAME${num}=${LoginId}${\n}
    
    ${resp}=  Encrypted Provider Login  ${LoginId}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${pid}  ${decrypted_data['id']}
    Set Test Variable  ${domain}  ${decrypted_data['sector']}
    Set Test Variable  ${subdomain}  ${decrypted_data['subSector']}
    Set Test Variable  ${firstname}  ${decrypted_data['firstName']}
    Set Test Variable  ${lastname}  ${decrypted_data['lastName']}

    Set Test Variable  ${email_id}  ${P_Email}${LoginId}.${test_mail}
    ${resp}=  Update Email   ${pid}   ${firstname}   ${lastname}   ${email_id}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${bs}=  FakerLibrary.company
    ${companySuffix}=  FakerLibrary.companySuffix
    ${parking}   Random Element   ${parkingType}
    ${24hours}    Random Element    ['True','False']
    ${url}=   FakerLibrary.url
    ${name3}=  FakerLibrary.word
    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    Set Test Variable  ${tz}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${description}=  FakerLibrary.catch_phrase

    ${b_loc}=  Create Dictionary  place=${city}   longitude=${longi}   lattitude=${latti}    googleMapUrl=${url}   pinCode=${postcode}  address=${address}  parkingType=${parking}  open24hours=${24hours}
    ${resp}=  Update Business Profile with kwargs   businessName=${bs}   businessUserName=${firstname}${SPACE}${lastname}   businessDesc=Description:${SPACE}${description}  shortName=${companySuffix}  baseLocation=${b_loc} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${fields}=   Get subDomain level Fields  ${domain}  ${subdomain}
    Log  ${fields.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${virtual_fields}=  get_Subdomainfields  ${fields.json()}

    ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${subdomain}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get specializations Sub Domain  ${domain}  ${subdomain}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${spec}=  Select Random Specializations   ${resp}

    ${resp}=  Update Business Profile with kwargs  specialization=${spec}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id}  ${resp.json()['id']} 

    ${resp}=  Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['onlinePresence']}==${bool[0]}   
        ${resp}=   Set jaldeeIntegration Settings    ${boolean[1]}  ${EMPTY}  ${EMPTY}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    ${resp}=  Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}  ${bool[1]}

    Remove Entry From File  ${bprof_file}  ${LoginId}

    ${custid}=  FakerLibrary.company
    ${first_word}=   Set Variable   ${custid.split()[0]}
    ${resp}=  Post CustomID  tddtest-${first_word}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Append To File  ${bprof_file}  ${LoginId}, ${PASSWORD}, tddtest-${first_word}${\n}
    
    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp}=   Enable Disable Appointment   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}  ${bool[1]}

    ${resp}=  Get jp finance settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableJaldeeFinance']}==${bool[0]}
        ${resp1}=    Enable Disable Jaldee Finance   ${toggle[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=  Get jp finance settings    
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableJaldeeFinance']}  ${bool[1]}

    ${resp}=  Get Waitlist Settings
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['filterByDept']}==${bool[1]}
        ${resp}=  Enable Disable Department  ${toggle[1]}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    ${resp}=  Get Waitlist Settings
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['filterByDept']}  ${bool[0]}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${lid}=  Create Sample Location
        ${resp}=   Get Location ById  ${lid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Test Variable  ${lid}  ${resp.json()[0]['id']}
        Set Test Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    ${resp}=    Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${SERVICE1}=    generate_unique_service_name  ${service_names}
        Append To List  ${service_names}  ${SERVICE1}   
        ${s_id}=  Create Sample Service  ${SERVICE1}  
    ELSE
        Set Test Variable  ${s_id}   ${resp.json()[0]['id']}
    END

    ${resp}=   Get Service By Id  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['maxBookingsAllowed']} <= 1
        ${description}=  FakerLibrary.catch_phrase
        # ${resp.json()['description']} - no description in get service or get service by id response.
        ${resp}=  Update Service  ${s_id}  ${resp.json()['name']}  ${description}  ${resp.json()['serviceDuration']}  ${resp.json()['isPrePayment']}  ${resp.json()['totalAmount']}  maxBookingsAllowed=${maxBookings}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    ${resp}=    Get Appointment Schedules
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp}=  Create Sample Schedule   ${lid}   ${s_id}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${sch_id}  ${resp.json()}
    ELSE
        Set Test Variable  ${sch_id}  ${resp.json()[0]['id']}
        Set Test Variable  ${lid}  ${resp.json()[0]['location']['id']}
        ${resp}=  Update Schedule with Services  ${sch_id}  ${resp.json()[0]}  ${s_id}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
    END





*** COMMENTS ***
JD-TC-LoginVerification-1

    [Documentation]  login with ${PUSERNAME42}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME42}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Run Keyword And Continue On Failure  Set Test Variable  ${pid}  ${decrypted_data['id']}
    Run Keyword And Continue On Failure  Set Test Variable  ${firstname}  ${decrypted_data['firstName']}  
    Run Keyword And Continue On Failure  Set Test Variable  ${lastname}  ${decrypted_data['lastName']}  
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['userName']}  ${firstname}${SPACE}${lastname}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['primaryLoginId']}  ${PUSERNAME42}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['userType']}  1
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['userTypeEnum']}  ${userType[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['accStatus']}  ${status[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['s3Url']}  https://jaldeelocal.s3.us-west-1.amazonaws.com
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['isProvider']}  ${bool[1]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['sector']}  foodJoints
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['subSector']}  coffeeShop
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['accountLicenseDetails']['accountLicense']['accountLicId']}  203
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}  1
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['accountLicenseDetails']['accountLicense']['base']}  ${bool[1]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['accountLicenseDetails']['accountLicense']['licenseTransactionType']}  New
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['accountLicenseDetails']['accountLicense']['renewedDays']}  0
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['accountLicenseDetails']['accountLicense']['renewedBy']}  Asha
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['accountLicenseDetails']['accountLicense']['type']}  Production
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['accountLicenseDetails']['accountLicense']['status']}  Active
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['accountLicenseDetails']['accountLicense']['name']}  Starter
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['accountLicenseDetails']['accountLicense']['displayName']}  Starter
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['accountLicenseDetails']['accountLicense']['invoicePending']}  ${bool[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['accountLicenseDetails']['accountLicense']['licPkgLevel']}  4
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['accountLicenseDetails']['addons']}  []
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['accountLicenseDetails']['dueAmount']}  0.0
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['firstCheckIn']}  ${bool[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['accountType']}  INDEPENDENT_SP
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['bProfileCreated']}  ${bool[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['securedUniquekey']}  7257bf2
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['adminPrivilege']}  ${bool[1]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['deptId']}  0
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['userTeams']}  []
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['bussLocs']}  [203]
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['showCsmrDataBase']}  ${bool[1]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['enableRbac']}  ${bool[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['multiFactorAuthenticationRequired']}  ${bool[0]}
    Run Keyword And Continue On Failure  Should Contain    ${decrypted_data['accountLicenseDetails']['accountLicense']}  dateApplied
    Run Keyword And Continue On Failure  Should Contain    ${decrypted_data['accountLicenseDetails']}  nextPaymentOn
    # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['accountLicenseDetails']['addons'][0]['accountLicId']}  3
    # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['accountLicenseDetails']['addons'][0]['licPkgOrAddonId']}  13
    # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['accountLicenseDetails']['addons'][0]['base']}  ${bool[0]}
    # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['accountLicenseDetails']['addons'][0]['licenseTransactionType']}  New
    # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['accountLicenseDetails']['addons'][0]['renewedDays']}  0
    # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['accountLicenseDetails']['addons'][0]['renewedBy']}  Asha
    # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['accountLicenseDetails']['addons'][0]['type']}  Production
    # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['accountLicenseDetails']['addons'][0]['status']}  ${status[0]}
    # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['accountLicenseDetails']['addons'][0]['name']}  QBoards - 100 Count
    # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['accountLicenseDetails']['addons'][0]['description']}  100 QBoards for Rs. 19999 per month
    # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['accountLicenseDetails']['addons'][0]['metricIdOfAddon']}  18
    # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['accountLicenseDetails']['addons'][0]['metricValueType']}  Number
    # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['accountLicenseDetails']['addons'][0]['addonValue']}  100
    # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['accountLicenseDetails']['addons'][0]['invoicePending']}  ${bool[0]}
    # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['accountLicenseDetails']['addons'][0]['licPkgLevel']}  0
    # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['accountLicenseDetails']['addons'][1]['accountLicId']}  4
    # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['accountLicenseDetails']['addons'][1]['licPkgOrAddonId']}  31
    # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['accountLicenseDetails']['addons'][1]['base']}  ${bool[0]}
    # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['accountLicenseDetails']['addons'][1]['licenseTransactionType']}  New
    # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['accountLicenseDetails']['addons'][1]['renewedDays']}  0
    # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['accountLicenseDetails']['addons'][1]['renewedBy']}  Asha
    # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['accountLicenseDetails']['addons'][1]['type']}  Production
    # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['accountLicenseDetails']['addons'][1]['status']}  ${status[0]}
    # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['accountLicenseDetails']['addons'][1]['name']}  Multi User - 1000 Count
    # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['accountLicenseDetails']['addons'][1]['description']}  Pack of 1000 Users for Rs. 399999 per month
    # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['accountLicenseDetails']['addons'][1]['metricIdOfAddon']}  21
    # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['accountLicenseDetails']['addons'][1]['metricValueType']}  Number
    # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['accountLicenseDetails']['addons'][1]['addonValue']}  1000
    # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['accountLicenseDetails']['addons'][1]['invoicePending']}  ${bool[0]}
    # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['accountLicenseDetails']['addons'][1]['licPkgLevel']}  0
    # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['accountLicenseDetails']['addons'][2]['accountLicId']}  5
    # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['accountLicenseDetails']['addons'][2]['licPkgOrAddonId']}  42
    # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['accountLicenseDetails']['addons'][2]['base']}  ${bool[0]}
    # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['accountLicenseDetails']['addons'][2]['licenseTransactionType']}  New
    # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['accountLicenseDetails']['addons'][2]['renewedDays']}  0
    # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['accountLicenseDetails']['addons'][2]['renewedBy']}  Asha
    # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['accountLicenseDetails']['addons'][2]['type']}  Production
    # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['accountLicenseDetails']['addons'][2]['status']}  ${status[0]}
    # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['accountLicenseDetails']['addons'][2]['name']}  WhatsApp Message - 10000 Messages
    # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['accountLicenseDetails']['addons'][2]['description']}  10000 WhatsApp Messages for Rs. 10000 per month
    # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['accountLicenseDetails']['addons'][2]['metricIdOfAddon']}  27
    # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['accountLicenseDetails']['addons'][2]['metricValueType']}  Number
    # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['accountLicenseDetails']['addons'][2]['addonValue']}  10000.0
    # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['accountLicenseDetails']['addons'][2]['invoicePending']}  ${bool[0]}
    # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['accountLicenseDetails']['addons'][2]['licPkgLevel']}  0
    
    
    # Run Keyword And Continue On Failure  Should Be Equal As Strings  