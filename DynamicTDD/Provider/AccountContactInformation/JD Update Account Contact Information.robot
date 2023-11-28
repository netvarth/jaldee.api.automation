*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Account
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 

*** Variables ***
${salutation}     MR

*** Test Cases ***
JD-TC-Update Account Contact information-1
	[Documentation]  Update account contact information with  signup through primaryphonenumber(update basic information)
    ${domresp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${domresp.status_code}  200

    ${len}=  Get Length  ${domresp.json()}
    ${len}=  Evaluate  ${len}-1
    ${PUSERNAME}=  Evaluate  ${PUSERNAME}+406000222
    Set Test Variable  ${d1}  ${domresp.json()[${len}]['domain']}    
    Set Test Variable  ${sd}  ${domresp.json()[${len}]['subDomains'][0]['subDomain']} 
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${d1}  ${sd}  ${PUSERNAME}   ${highest_package[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAME}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAME}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Encrypted Provider Login  ${PUSERNAME}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${pro_id}  ${resp.json()['id']}
    Set Suite Variable  ${PUSERNAME}
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERNAME}${\n}  
    ${pid}=  get_acc_id  ${PUSERNAME}
    ${resp}=  Get Provider Details    ${pro_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['basicInfo']['id']}              ${pro_id}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['firstName']}       ${firstname}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['lastName']}        ${lastname}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['mobile']}          ${PUSERNAME}
    # Should Be Equal As Strings  ${resp.json()['basicInfo']['emailVerified']}   ${bool[0]} 
    # Should Be Equal As Strings  ${resp.json()['basicInfo']['phoneVerified']}   ${bool[1]} 
    Set Test Variable  ${country_code}   ${resp.json()['basicInfo']['countryCode']}     

    Set Suite Variable  ${countryCode_CC0}    ${countryCodes[0]}
    ${resp}=   Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    comment   WAITLISTADD
    Should Be Equal As Strings  ${resp.json()[0]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['eventType']}     ${EventType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['email']}         []
    Should Be Equal As Strings  ${resp.json()[0]['sms'][0]['number']}           ${PUSERNAME} 
    Should Be Equal As Strings  ${resp.json()[0]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]['number']}       ${PUSERNAME} 
    Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[0]['sms'][0]}        ${PUSERNAME}
    # Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]}    ${PUSERNAME}
    comment   WAITLIST-CANCEL
    Should Be Equal As Strings  ${resp.json()[1]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[1]['eventType']}     ${EventType[1]}
    Should Be Equal As Strings  ${resp.json()[1]['email']}         []
    Should Be Equal As Strings  ${resp.json()[1]['sms'][0]['number']}           ${PUSERNAME} 
    Should Be Equal As Strings  ${resp.json()[1]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]['number']}       ${PUSERNAME} 
    Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[1]['sms'][0]}        ${PUSERNAME}
    # Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]}    ${PUSERNAME}
    comment   APPOINTMENTADD
    Should Be Equal As Strings  ${resp.json()[2]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[2]['eventType']}     ${EventType[7]}
    Should Be Equal As Strings  ${resp.json()[2]['email']}         []
    Should Be Equal As Strings  ${resp.json()[2]['sms'][0]['number']}           ${PUSERNAME} 
    Should Be Equal As Strings  ${resp.json()[2]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]['number']}       ${PUSERNAME} 
    Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[2]['sms'][0]}        ${PUSERNAME}
    # Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]}    ${PUSERNAME}
    comment   APPOINTMENT-CANCEL
    Should Be Equal As Strings  ${resp.json()[3]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[3]['eventType']}     ${EventType[8]}
    Should Be Equal As Strings  ${resp.json()[3]['email']}         []
    Should Be Equal As Strings  ${resp.json()[3]['sms'][0]['number']}           ${PUSERNAME} 
    Should Be Equal As Strings  ${resp.json()[3]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]['number']}       ${PUSERNAME} 
    Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[3]['sms'][0]}        ${PUSERNAME}
    # Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]}    ${PUSERNAME}
    comment   DONATION
    Should Be Equal As Strings  ${resp.json()[4]['resourceType']}  ${NotificationResourceType[3]}
    Should Be Equal As Strings  ${resp.json()[4]['eventType']}     ${EventType[10]}
    Should Be Equal As Strings  ${resp.json()[4]['email']}         []
    Should Be Equal As Strings  ${resp.json()[4]['sms'][0]['number']}           ${PUSERNAME} 
    Should Be Equal As Strings  ${resp.json()[4]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[4]['pushMsg'][0]['number']}       ${PUSERNAME} 
    Should Be Equal As Strings  ${resp.json()[4]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[4]['sms'][0]}        ${PUSERNAME}
    # Should Be Equal As Strings  ${resp.json()[4]['pushMsg'][0]}    ${PUSERNAME}
    comment   LICENSE
    Should Be Equal As Strings  ${resp.json()[5]['resourceType']}  ${NotificationResourceType[2]}
    Should Be Equal As Strings  ${resp.json()[5]['eventType']}     ${EventType[9]}
    Should Be Equal As Strings  ${resp.json()[5]['email']}        []
    Should Be Equal As Strings  ${resp.json()[5]['sms'][0]['number']}           ${PUSERNAME} 
    Should Be Equal As Strings  ${resp.json()[5]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[5]['pushMsg'][0]['number']}       ${PUSERNAME} 
    Should Be Equal As Strings  ${resp.json()[5]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[5]['sms'][0]}       ${PUSERNAME}
    # Should Be Equal As Strings  ${resp.json()[5]['pushMsg'][0]}   ${PUSERNAME}

    ${resp}=  Get Account contact information
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['account']}             ${pid}
    Should Be Equal As Strings  ${resp.json()['primaryPhoneNumber']}  ${PUSERNAME}
    Should Be Equal As Strings  ${resp.json()['contactFirstName']}    ${firstname}
    Should Be Equal As Strings  ${resp.json()['contactLastName']}     ${lastname}
    Should Be Equal As Strings  ${resp.json()['emailVerified']}       ${bool[0]} 
    Should Be Equal As Strings  ${resp.json()['phoneVerified']}       ${bool[1]} 

    ${firstname1}=  FakerLibrary.first_name
    ${lastname1}=  FakerLibrary.last_name
    ${whatsapp1}=   Evaluate  ${PUSERNAME}+406000222
    Set Suite Variable   ${whatsapp1} 
    ${secondary-phone}=  Evaluate  ${PUSERNAME}+406000222
    Set Suite Variable   ${secondary-phone} 
    Set Test Variable  ${email}  ${firstname}${PUSERNAME0}${C_Email}.${test_mail}
    Set Suite Variable  ${email0}  ${firstname1}${PUSERNAME0}${C_Email}.${test_mail}
    ${resp}=  Update Account contact information   ${PUSERNAME}   ${email}  ${secondary-phone}   ${whatsapp1}  ${email0}  ${salutation}  ${firstname1}  ${lastname1}  ${country_code}  ${country_code}  ${country_code}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Get Account contact information
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['account']}             ${pid}
    Should Be Equal As Strings  ${resp.json()['primaryPhoneNumber']}  ${PUSERNAME}
    Should Be Equal As Strings  ${resp.json()['contactFirstName']}    ${firstname1}
    Should Be Equal As Strings  ${resp.json()['contactLastName']}     ${lastname1}
    Should Be Equal As Strings  ${resp.json()['salutation']}          ${salutation}
    Should Be Equal As Strings  ${resp.json()['whatsappPhoneNumber']}   ${whatsapp1}
    Should Be Equal As Strings  ${resp.json()['primaryEmail']}         ${email}
    Should Be Equal As Strings  ${resp.json()['secondaryPhoneNumber']}  ${secondary-phone}
    Should Be Equal As Strings  ${resp.json()['emailVerified']}         ${bool[0]} 
    Should Be Equal As Strings  ${resp.json()['phoneVerified']}         ${bool[1]} 
    
    ${resp}=   Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    comment   LICENSE
    Should Be Equal As Strings  ${resp.json()[5]['resourceType']}  ${NotificationResourceType[2]}
    Should Be Equal As Strings  ${resp.json()[5]['eventType']}     ${EventType[9]}
    Should Be Equal As Strings  ${resp.json()[5]['email'][0]}      ${email} 
    Should Be Equal As Strings  ${resp.json()[5]['sms'][0]['number']}           ${PUSERNAME} 
    Should Be Equal As Strings  ${resp.json()[5]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[5]['pushMsg'][0]['number']}       ${PUSERNAME} 
    Should Be Equal As Strings  ${resp.json()[5]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[5]['sms'][0]}        ${PUSERNAME}
    # Should Be Equal As Strings  ${resp.json()[5]['pushMsg'][0]}    ${PUSERNAME}

JD-TC-Update Account Contact information-2
	[Documentation]  Update account contact information with  signup through primaryphonenumber(update basic information)here first update provider details with email as null then update contact info
    ${domresp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${domresp.status_code}  200
    ${len}=  Get Length  ${domresp.json()}
    ${len}=  Evaluate  ${len}-1
    ${PUSERNAME0}=  Evaluate  ${PUSERNAME}+406718222
    Set Test Variable  ${d1}  ${domresp.json()[${len}]['domain']}    
    Set Test Variable  ${sd}  ${domresp.json()[${len}]['subDomains'][0]['subDomain']} 
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${d1}  ${sd}  ${PUSERNAME0}   ${highest_package[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAME0}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAME0}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Encrypted Provider Login  ${PUSERNAME0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${pro_id0}  ${decrypted_data['id']}
    # Set Test Variable  ${pro_id0}  ${resp.json()['id']}
    Set Suite Variable  ${PUSERNAME0}
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERNAME0}${\n}  
    ${pid}=  get_acc_id  ${PUSERNAME0}
    ${resp}=  Get Provider Details    ${pro_id0} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['basicInfo']['id']}              ${pro_id0}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['firstName']}       ${firstname}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['lastName']}        ${lastname}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['mobile']}          ${PUSERNAME0}
    # Should Be Equal As Strings  ${resp.json()['basicInfo']['emailVerified']}   ${bool[0]} 
    # Should Be Equal As Strings  ${resp.json()['basicInfo']['phoneVerified']}   ${bool[1]} 
    Set Test Variable  ${country_code}   ${resp.json()['basicInfo']['countryCode']} 

    ${resp}=   Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    comment   WAITLISTADD
    Should Be Equal As Strings  ${resp.json()[0]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['eventType']}  ${EventType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['email']}      []
    Should Be Equal As Strings  ${resp.json()[0]['sms'][0]['number']}           ${PUSERNAME0} 
    Should Be Equal As Strings  ${resp.json()[0]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]['number']}       ${PUSERNAME0} 
    Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[0]['sms'][0]}      ${PUSERNAME0}
    # Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]}  ${PUSERNAME0}
    comment   WAITLIST-CANCEL
    Should Be Equal As Strings  ${resp.json()[1]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[1]['eventType']}   ${EventType[1]}
    Should Be Equal As Strings  ${resp.json()[1]['email']}       []
    Should Be Equal As Strings  ${resp.json()[1]['sms'][0]['number']}           ${PUSERNAME0} 
    Should Be Equal As Strings  ${resp.json()[1]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]['number']}       ${PUSERNAME0} 
    Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[1]['sms'][0]}      ${PUSERNAME0}
    # Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]}  ${PUSERNAME0}
    comment   APPOINTMENTADD
    Should Be Equal As Strings  ${resp.json()[2]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[2]['eventType']}     ${EventType[7]}
    Should Be Equal As Strings  ${resp.json()[2]['email']}         []
    Should Be Equal As Strings  ${resp.json()[2]['sms'][0]['number']}           ${PUSERNAME0} 
    Should Be Equal As Strings  ${resp.json()[2]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]['number']}       ${PUSERNAME0} 
    Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[2]['sms'][0]}        ${PUSERNAME0}
    # Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]}    ${PUSERNAME0}
    comment   APPOINTMENT-CANCEL
    Should Be Equal As Strings  ${resp.json()[3]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[3]['eventType']}     ${EventType[8]}
    Should Be Equal As Strings  ${resp.json()[3]['email']}         []
    Should Be Equal As Strings  ${resp.json()[3]['sms'][0]['number']}           ${PUSERNAME0} 
    Should Be Equal As Strings  ${resp.json()[3]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]['number']}       ${PUSERNAME0} 
    Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[3]['sms'][0]}        ${PUSERNAME0}
    # Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]}    ${PUSERNAME0}
    comment   DONATION
    Should Be Equal As Strings  ${resp.json()[4]['resourceType']}  ${NotificationResourceType[3]}
    Should Be Equal As Strings  ${resp.json()[4]['eventType']}     ${EventType[10]}
    Should Be Equal As Strings  ${resp.json()[4]['email']}         []
    Should Be Equal As Strings  ${resp.json()[4]['sms'][0]['number']}           ${PUSERNAME0} 
    Should Be Equal As Strings  ${resp.json()[4]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[4]['pushMsg'][0]['number']}       ${PUSERNAME0} 
    Should Be Equal As Strings  ${resp.json()[4]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[4]['sms'][0]}        ${PUSERNAME0}
    # Should Be Equal As Strings  ${resp.json()[4]['pushMsg'][0]}    ${PUSERNAME0}
    comment   LICENSE
    Should Be Equal As Strings  ${resp.json()[5]['resourceType']}  ${NotificationResourceType[2]}
    Should Be Equal As Strings  ${resp.json()[5]['eventType']}    ${EventType[9]}
    Should Be Equal As Strings  ${resp.json()[5]['email']}        []
    Should Be Equal As Strings  ${resp.json()[5]['sms'][0]['number']}           ${PUSERNAME0} 
    Should Be Equal As Strings  ${resp.json()[5]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[5]['pushMsg'][0]['number']}       ${PUSERNAME0} 
    Should Be Equal As Strings  ${resp.json()[5]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[5]['sms'][0]}       ${PUSERNAME0}
    # Should Be Equal As Strings  ${resp.json()[5]['pushMsg'][0]}   ${PUSERNAME0}

    ${resp}=  Get Account contact information
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['account']}             ${pid}
    Should Be Equal As Strings  ${resp.json()['primaryPhoneNumber']}  ${PUSERNAME0}
    Should Be Equal As Strings  ${resp.json()['contactFirstName']}   ${firstname}
    Should Be Equal As Strings  ${resp.json()['contactLastName']}    ${lastname}
    Should Be Equal As Strings  ${resp.json()['emailVerified']}      ${bool[0]} 
    Should Be Equal As Strings  ${resp.json()['phoneVerified']}      ${bool[1]} 

    ${firstname1}=  FakerLibrary.first_name
    ${lastname1}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}=  Random Element    ${Genderlist}
    # Set Test Variable  ${email}  ${firstname1}${PUSERNAME0}${C_Email}.${test_mail}
    ${resp}=   Update Service Provider With Emailid    ${pro_id0}  ${firstName1}  ${lastName1}  ${gender}  ${dob}  ${EMPTY}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Provider Details    ${pro_id0} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['basicInfo']['id']}              ${pro_id0}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['firstName']}       ${firstname1}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['lastName']}        ${lastname1}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['mobile']}          ${PUSERNAME0}
    # Should Be Equal As Strings  ${resp.json()['basicInfo']['emailVerified']}   ${bool[0]} 
    # Should Be Equal As Strings  ${resp.json()['basicInfo']['phoneVerified']}   ${bool[1]} 

    ${resp}=  Get Account contact information
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['account']}             ${pid}
    Should Be Equal As Strings  ${resp.json()['primaryPhoneNumber']}  ${PUSERNAME0}
    Should Be Equal As Strings  ${resp.json()['contactFirstName']}  ${firstname1}
    Should Be Equal As Strings  ${resp.json()['contactLastName']}   ${lastname1}
    Should Be Equal As Strings  ${resp.json()['primaryEmail']}      ${EMPTY}
    Should Be Equal As Strings  ${resp.json()['emailVerified']}     ${bool[0]} 
    Should Be Equal As Strings  ${resp.json()['phoneVerified']}     ${bool[1]} 

    ${resp}=   Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    # no change

    ${firstname2}=  FakerLibrary.first_name
    ${lastname2}=  FakerLibrary.last_name
    ${whatsapp2}=   Evaluate  ${PUSERNAME}+406400222
    ${secondary-phone}=  Evaluate  ${PUSERNAME}+406700223
    Set Test Variable  ${email2}  ${firstname2}${PUSERNAME0}${C_Email}.${test_mail}
    # Set Suite Variable  ${email0}  ${firstname1}${PUSERNAME0}${C_Email}.${test_mail}
    ${resp}=  Update Account contact information   ${PUSERNAME0}   ${email2}  ${secondary-phone}   ${whatsapp2}  ${EMPTY}  ${salutation}  ${firstname2}  ${lastname2}  ${country_code}  ${country_code}  ${country_code}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Get Account contact information
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['account']}               ${pid}
    Should Be Equal As Strings  ${resp.json()['primaryPhoneNumber']}    ${PUSERNAME0}
    Should Be Equal As Strings  ${resp.json()['contactFirstName']}      ${firstname2}
    Should Be Equal As Strings  ${resp.json()['contactLastName']}       ${lastname2}
    Should Be Equal As Strings  ${resp.json()['salutation']}            ${salutation}
    Should Be Equal As Strings  ${resp.json()['primaryEmail']}          ${email2}
    Should Be Equal As Strings  ${resp.json()['whatsappPhoneNumber']}   ${whatsapp2}
    Should Be Equal As Strings  ${resp.json()['emailVerified']}         ${bool[0]} 
    Should Be Equal As Strings  ${resp.json()['phoneVerified']}         ${bool[1]} 
    
    ${resp}=   Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    comment   LICENSE
    Should Be Equal As Strings  ${resp.json()[5]['resourceType']}   ${NotificationResourceType[2]}
    Should Be Equal As Strings  ${resp.json()[5]['eventType']}      ${EventType[9]}
    Should Be Equal As Strings  ${resp.json()[5]['email'][0]}       ${email2} 
    Should Be Equal As Strings  ${resp.json()[5]['sms'][0]['number']}           ${PUSERNAME0} 
    Should Be Equal As Strings  ${resp.json()[5]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[5]['pushMsg'][0]['number']}       ${PUSERNAME0} 
    Should Be Equal As Strings  ${resp.json()[5]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[5]['sms'][0]}         ${PUSERNAME0}
    # Should Be Equal As Strings  ${resp.json()[5]['pushMsg'][0]}     ${PUSERNAME0}


JD-TC-Update Account Contact information-3
	[Documentation]   Update account contact information with  signup through primaryphonenumber(update basic information)here first update provider details then update contact info
    
    ${domresp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${domresp.status_code}  200
    ${len}=  Get Length  ${domresp.json()}
    ${len}=  Evaluate  ${len}-1
    ${PUSERNAME_00}=  Evaluate  ${PUSERNAME}+406794222
    Set Test Variable  ${d1}  ${domresp.json()[${len}]['domain']}    
    Set Test Variable  ${sd}  ${domresp.json()[${len}]['subDomains'][0]['subDomain']} 
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${d1}  ${sd}  ${PUSERNAME_00}   ${highest_package[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAME_00}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAME_00}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_00}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${pro_id00}  ${resp.json()['id']}
    Set Suite Variable  ${PUSERNAME_00}
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERNAME_00}${\n}  
    ${pid}=  get_acc_id  ${PUSERNAME_00}
    ${resp}=  Get Provider Details    ${pro_id00} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['basicInfo']['id']}              ${pro_id00}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['firstName']}       ${firstname}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['lastName']}        ${lastname}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['mobile']}          ${PUSERNAME_00}
    # Should Be Equal As Strings  ${resp.json()['basicInfo']['emailVerified']}   ${bool[0]} 
    # Should Be Equal As Strings  ${resp.json()['basicInfo']['phoneVerified']}   ${bool[1]} 
    Set Test Variable  ${country_code}   ${resp.json()['basicInfo']['countryCode']} 

    ${resp}=   Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    comment   WAITLISTADD
    Should Be Equal As Strings  ${resp.json()[0]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['eventType']}     ${EventType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['email']}         []
    Should Be Equal As Strings  ${resp.json()[0]['sms'][0]['number']}           ${PUSERNAME_00} 
    Should Be Equal As Strings  ${resp.json()[0]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]['number']}       ${PUSERNAME_00} 
    Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[0]['sms'][0]}        ${PUSERNAME_00}
    # Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]}     ${PUSERNAME_00}
    comment   WAITLIST-CANCEL
    Should Be Equal As Strings  ${resp.json()[1]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[1]['eventType']}      ${EventType[1]}
    Should Be Equal As Strings  ${resp.json()[1]['email']}          []
    Should Be Equal As Strings  ${resp.json()[1]['sms'][0]['number']}           ${PUSERNAME_00} 
    Should Be Equal As Strings  ${resp.json()[1]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]['number']}       ${PUSERNAME_00} 
    Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[1]['sms'][0]}        ${PUSERNAME_00}
    # Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]}     ${PUSERNAME_00}
    comment   APPOINTMENTADD
    Should Be Equal As Strings  ${resp.json()[2]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[2]['eventType']}     ${EventType[7]}
    Should Be Equal As Strings  ${resp.json()[2]['email']}         []
    Should Be Equal As Strings  ${resp.json()[2]['sms'][0]['number']}           ${PUSERNAME_00} 
    Should Be Equal As Strings  ${resp.json()[2]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]['number']}       ${PUSERNAME_00} 
    Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[2]['sms'][0]}        ${PUSERNAME_00}
    # Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]}    ${PUSERNAME_00}
    comment   APPOINTMENT-CANCEL
    Should Be Equal As Strings  ${resp.json()[3]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[3]['eventType']}     ${EventType[8]}
    Should Be Equal As Strings  ${resp.json()[3]['email']}         []
    Should Be Equal As Strings  ${resp.json()[3]['sms'][0]['number']}           ${PUSERNAME_00} 
    Should Be Equal As Strings  ${resp.json()[3]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]['number']}       ${PUSERNAME_00} 
    Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[3]['sms'][0]}        ${PUSERNAME_00}
    # Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]}    ${PUSERNAME_00}
    comment   DONATION
    Should Be Equal As Strings  ${resp.json()[4]['resourceType']}  ${NotificationResourceType[3]}
    Should Be Equal As Strings  ${resp.json()[4]['eventType']}     ${EventType[10]}
    Should Be Equal As Strings  ${resp.json()[4]['email']}         []
    Should Be Equal As Strings  ${resp.json()[4]['sms'][0]['number']}           ${PUSERNAME_00} 
    Should Be Equal As Strings  ${resp.json()[4]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[4]['pushMsg'][0]['number']}       ${PUSERNAME_00} 
    Should Be Equal As Strings  ${resp.json()[4]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[4]['sms'][0]}        ${PUSERNAME_00}
    # Should Be Equal As Strings  ${resp.json()[4]['pushMsg'][0]}    ${PUSERNAME_00}
    comment   LICENSE
    Should Be Equal As Strings  ${resp.json()[5]['resourceType']}  ${NotificationResourceType[2]}
    Should Be Equal As Strings  ${resp.json()[5]['eventType']}     ${EventType[9]}
    Should Be Equal As Strings  ${resp.json()[5]['email']}         []
    Should Be Equal As Strings  ${resp.json()[5]['sms'][0]['number']}           ${PUSERNAME_00} 
    Should Be Equal As Strings  ${resp.json()[5]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[5]['pushMsg'][0]['number']}       ${PUSERNAME_00} 
    Should Be Equal As Strings  ${resp.json()[5]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[5]['sms'][0]}        ${PUSERNAME_00}
    # Should Be Equal As Strings  ${resp.json()[5]['pushMsg'][0]}    ${PUSERNAME_00}

    ${resp}=  Get Account contact information
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['account']}             ${pid}
    Should Be Equal As Strings  ${resp.json()['primaryPhoneNumber']}  ${PUSERNAME_00}
    Should Be Equal As Strings  ${resp.json()['contactFirstName']}  ${firstname}
    Should Be Equal As Strings  ${resp.json()['contactLastName']}   ${lastname}
    Should Be Equal As Strings  ${resp.json()['emailVerified']}     ${bool[0]} 
    Should Be Equal As Strings  ${resp.json()['phoneVerified']}     ${bool[1]} 

    ${firstname1}=  FakerLibrary.first_name
    ${lastname1}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}=  Random Element    ${Genderlist}
    Set Test Variable  ${email}  ${firstname1}${PUSERNAME0}${C_Email}.${test_mail}
    ${resp}=   Update Service Provider With Emailid    ${pro_id00}  ${firstName1}  ${lastName1}  ${gender}  ${dob}  ${email}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Provider Details    ${pro_id00} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['basicInfo']['id']}              ${pro_id00}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['firstName']}       ${firstname1}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['lastName']}        ${lastname1}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['mobile']}          ${PUSERNAME_00}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['email']}           ${email}
    # Should Be Equal As Strings  ${resp.json()['basicInfo']['emailVerified']}   ${bool[1]} 
    # Should Be Equal As Strings  ${resp.json()['basicInfo']['phoneVerified']}   ${bool[1]} 

    ${resp}=  Get Account contact information
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['account']}             ${pid}
    Should Be Equal As Strings  ${resp.json()['primaryPhoneNumber']}  ${PUSERNAME_00}
    Should Be Equal As Strings  ${resp.json()['contactFirstName']}  ${firstname1}
    Should Be Equal As Strings  ${resp.json()['contactLastName']}   ${lastname1}
    Should Be Equal As Strings  ${resp.json()['primaryEmail']}      ${email}
    Should Be Equal As Strings  ${resp.json()['emailVerified']}     ${bool[0]} 
    Should Be Equal As Strings  ${resp.json()['phoneVerified']}     ${bool[1]} 

    ${resp}=   Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    # no change

    ${firstname2}=  FakerLibrary.first_name
    ${lastname2}=  FakerLibrary.last_name
    ${whatsapp2}=   Evaluate  ${PUSERNAME}+406400222
    ${secondary-phone}=  Evaluate  ${PUSERNAME}+406700223
    Set Test Variable  ${email2}  ${firstname2}${PUSERNAME0}${C_Email}.${test_mail}
    # Set Suite Variable  ${email0}  ${firstname1}${PUSERNAME0}${C_Email}.${test_mail}
    ${resp}=  Update Account contact information   ${PUSERNAME_00}   ${email2}  ${secondary-phone}   ${whatsapp2}  ${EMPTY}  ${salutation}  ${firstname2}  ${lastname2}  ${country_code}  ${country_code}  ${country_code}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Get Account contact information
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['account']}               ${pid}
    Should Be Equal As Strings  ${resp.json()['primaryPhoneNumber']}    ${PUSERNAME_00}
    Should Be Equal As Strings  ${resp.json()['contactFirstName']}      ${firstname2}
    Should Be Equal As Strings  ${resp.json()['contactLastName']}       ${lastname2}
    Should Be Equal As Strings  ${resp.json()['salutation']}            ${salutation}
    Should Be Equal As Strings  ${resp.json()['primaryEmail']}          ${email2}
    Should Be Equal As Strings  ${resp.json()['whatsappPhoneNumber']}   ${whatsapp2}
    Should Be Equal As Strings  ${resp.json()['emailVerified']}         ${bool[0]} 
    Should Be Equal As Strings  ${resp.json()['phoneVerified']}         ${bool[1]} 
    
    ${resp}=   Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    comment   LICENSE
    Should Be Equal As Strings  ${resp.json()[5]['resourceType']}  ${NotificationResourceType[2]}
    Should Be Equal As Strings  ${resp.json()[5]['eventType']}     ${EventType[9]}
    Should Be Equal As Strings  ${resp.json()[5]['email'][0]}      ${email2} 
    Should Be Equal As Strings  ${resp.json()[5]['sms'][0]['number']}           ${PUSERNAME_00} 
    Should Be Equal As Strings  ${resp.json()[5]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[5]['pushMsg'][0]['number']}       ${PUSERNAME_00} 
    Should Be Equal As Strings  ${resp.json()[5]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[5]['sms'][0]}        ${PUSERNAME_00}
    # Should Be Equal As Strings  ${resp.json()[5]['pushMsg'][0]}    ${PUSERNAME_00}


JD-TC-Update Account Contact information-4
	[Documentation]  Update account contact information with  signup through email and update with different email(update basic information)
    ${domresp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${domresp.status_code}  200
    ${len}=  Get Length  ${domresp.json()}
    ${len}=  Evaluate  ${len}-1
    ${PUSERNAME1}=  Evaluate  ${PUSERNAME}+406010222
    Set Test Variable  ${d1}  ${domresp.json()[${len}]['domain']}    
    Set Test Variable  ${sd}  ${domresp.json()[${len}]['subDomains'][0]['subDomain']} 
    ${firstname}=  FakerLibrary.first_name
    Set Suite Variable  ${firstname}
    ${lastname}=  FakerLibrary.last_name
    Set Suite Variable   ${lastname}
    ${highest_package}=  get_highest_license_pkg
    Set Suite Variable  ${e-mail}  ${firstname}${PUSERNAME1}${C_Email}.${test_mail}
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${e-mail}  ${d1}  ${sd}  ${PUSERNAME1}   ${highest_package[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${e-mail}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${e-mail}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Encrypted Provider Login  ${PUSERNAME1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${pro_id1}  ${resp.json()['id']}
    Set Suite Variable  ${PUSERNAME1}
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERNAME1}${\n}  
    ${pid}=  get_acc_id  ${PUSERNAME1}
    ${resp}=  Get Provider Details    ${pro_id1} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['basicInfo']['id']}              ${pro_id1}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['firstName']}       ${firstname}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['lastName']}        ${lastname}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['mobile']}          ${PUSERNAME1}
    # Should Be Equal As Strings  ${resp.json()['basicInfo']['emailVerified']}   ${bool[1]} 
    # Should Be Equal As Strings  ${resp.json()['basicInfo']['phoneVerified']}   ${bool[0]} 
    Set Test Variable  ${country_code}   ${resp.json()['basicInfo']['countryCode']} 

    ${resp}=   Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    comment   WAITLISTADD
    Should Be Equal As Strings  ${resp.json()[0]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['eventType']}   ${EventType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['email'][0]}    ${e-mail}
    Should Be Equal As Strings  ${resp.json()[0]['sms'][0]['number']}           ${PUSERNAME1} 
    Should Be Equal As Strings  ${resp.json()[0]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]['number']}       ${PUSERNAME1} 
    Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[0]['sms'][0]}      ${PUSERNAME1}
    # Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]}  ${PUSERNAME1}
    comment   WAITLIST-CANCEL
    Should Be Equal As Strings  ${resp.json()[1]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[1]['eventType']}    ${EventType[1]}
    Should Be Equal As Strings  ${resp.json()[1]['email'][0]}    ${e-mail}
    Should Be Equal As Strings  ${resp.json()[1]['sms'][0]['number']}           ${PUSERNAME1} 
    Should Be Equal As Strings  ${resp.json()[1]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]['number']}       ${PUSERNAME1} 
    Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[1]['sms'][0]}      ${PUSERNAME1}
    # Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]}  ${PUSERNAME1}
    comment   APPOINTMENTADD
    Should Be Equal As Strings  ${resp.json()[2]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[2]['eventType']}    ${EventType[7]}
    Should Be Equal As Strings  ${resp.json()[2]['email'][0]}    ${e-mail}
    Should Be Equal As Strings  ${resp.json()[2]['sms'][0]['number']}           ${PUSERNAME1} 
    Should Be Equal As Strings  ${resp.json()[2]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]['number']}       ${PUSERNAME1} 
    Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[2]['sms'][0]}      ${PUSERNAME1}
    # Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]}  ${PUSERNAME1}
    comment   APPOINTMENT-CANCEL
    Should Be Equal As Strings  ${resp.json()[3]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[3]['eventType']}     ${EventType[8]}
    Should Be Equal As Strings  ${resp.json()[3]['email'][0]}     ${e-mail}
    Should Be Equal As Strings  ${resp.json()[3]['sms'][0]['number']}           ${PUSERNAME1} 
    Should Be Equal As Strings  ${resp.json()[3]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]['number']}       ${PUSERNAME1} 
    Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[3]['sms'][0]}       ${PUSERNAME1}
    # Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]}   ${PUSERNAME1}
    comment   DONATION
    Should Be Equal As Strings  ${resp.json()[4]['resourceType']}  ${NotificationResourceType[3]}
    Should Be Equal As Strings  ${resp.json()[4]['eventType']}     ${EventType[10]}
    Should Be Equal As Strings  ${resp.json()[4]['email'][0]}      ${e-mail}
    Should Be Equal As Strings  ${resp.json()[4]['sms'][0]['number']}           ${PUSERNAME1} 
    Should Be Equal As Strings  ${resp.json()[4]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[4]['pushMsg'][0]['number']}       ${PUSERNAME1} 
    Should Be Equal As Strings  ${resp.json()[4]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[4]['sms'][0]}        ${PUSERNAME1}
    # Should Be Equal As Strings  ${resp.json()[4]['pushMsg'][0]}    ${PUSERNAME1}
    comment   LICENSE
    Should Be Equal As Strings  ${resp.json()[5]['resourceType']}  ${NotificationResourceType[2]}
    Should Be Equal As Strings  ${resp.json()[5]['eventType']}     ${EventType[9]}
    Should Be Equal As Strings  ${resp.json()[5]['email'][0]}      ${e-mail}
    Should Be Equal As Strings  ${resp.json()[5]['sms'][0]['number']}           ${PUSERNAME1} 
    Should Be Equal As Strings  ${resp.json()[5]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[5]['pushMsg'][0]['number']}       ${PUSERNAME1} 
    Should Be Equal As Strings  ${resp.json()[5]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[5]['sms'][0]}        ${PUSERNAME1}
    # Should Be Equal As Strings  ${resp.json()[5]['pushMsg'][0]}    ${PUSERNAME1}

    ${resp}=  Get Account contact information
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['account']}             ${pid}
    Should Be Equal As Strings  ${resp.json()['primaryPhoneNumber']}  ${PUSERNAME1}
    Should Be Equal As Strings  ${resp.json()['contactFirstName']}  ${firstname}
    Should Be Equal As Strings  ${resp.json()['contactLastName']}   ${lastname}
    Should Be Equal As Strings  ${resp.json()['primaryEmail']}      ${e-mail}
    Should Be Equal As Strings  ${resp.json()['emailVerified']}     ${bool[1]} 
    Should Be Equal As Strings  ${resp.json()['phoneVerified']}     ${bool[0]} 
    ${firstname1}=  FakerLibrary.first_name
    ${lastname1}=  FakerLibrary.last_name
    ${whatsapp}=   Evaluate  ${PUSERNAME}+406000223
    ${secondary-phone}=  Evaluate  ${PUSERNAME}+406056222
    Set Suite Variable  ${email1}  ${firstname1}${PUSERNAME1}${C_Email}.${test_mail}
    ${resp}=  Update Account contact information   ${PUSERNAME1}   ${email1}  ${secondary-phone}   ${whatsapp}  ${None}  ${salutation}  ${firstname1}  ${lastname1}  ${country_code}  ${country_code}  ${country_code} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Get Account contact information
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['account']}               ${pid}
    Should Be Equal As Strings  ${resp.json()['primaryPhoneNumber']}    ${PUSERNAME1}
    Should Be Equal As Strings  ${resp.json()['contactFirstName']}      ${firstname1}
    Should Be Equal As Strings  ${resp.json()['contactLastName']}       ${lastname1}
    Should Be Equal As Strings  ${resp.json()['salutation']}            ${salutation}
    Should Be Equal As Strings  ${resp.json()['whatsappPhoneNumber']}   ${whatsapp}
    Should Be Equal As Strings  ${resp.json()['primaryEmail']}      ${email1}
    Should Be Equal As Strings  ${resp.json()['emailVerified']}     ${bool[0]} 
    Should Be Equal As Strings  ${resp.json()['phoneVerified']}     ${bool[0]} 
    ${resp}=   Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    comment   LICENSE
    Should Be Equal As Strings  ${resp.json()[5]['resourceType']}  ${NotificationResourceType[2]}
    Should Be Equal As Strings  ${resp.json()[5]['eventType']}     ${EventType[9]}
    Should Be Equal As Strings  ${resp.json()[5]['email'][0]}      ${email1}
    Should Be Equal As Strings  ${resp.json()[5]['sms'][0]['number']}           ${PUSERNAME1} 
    Should Be Equal As Strings  ${resp.json()[5]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[5]['pushMsg'][0]['number']}       ${PUSERNAME1} 
    Should Be Equal As Strings  ${resp.json()[5]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[5]['sms'][0]}        ${PUSERNAME1}
    # Should Be Equal As Strings  ${resp.json()[5]['pushMsg'][0]}    ${PUSERNAME1}


JD-TC-Update Account Contact information-5
	[Documentation]  Update account contact information with  branch signup through phonenumber
    ${iscorp_subdomains}=  get_iscorp_subdomains  1
    Log  ${iscorp_subdomains}
    Set Suite Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
    Set Suite Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
    Set Suite Variable  ${sub_domain_id}   ${iscorp_subdomains[0]['subdomainId']}
    ${firstname_A}=  FakerLibrary.first_name
    Set Suite Variable  ${firstname_A}
    ${lastname_A}=  FakerLibrary.last_name
    Set Suite Variable  ${lastname_A}
    ${MUSERNAME_K}=  Evaluate  ${MUSERNAME}+406014222
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname_A}  ${lastname_A}  ${None}  ${domains}  ${sub_domains}  ${MUSERNAME_K}    ${highest_package[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${MUSERNAME_K}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${MUSERNAME_K}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Encrypted Provider Login  ${MUSERNAME_K}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${MUSERNAME_K}${\n}
    Set Suite Variable  ${MUSERNAME_K}
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${MUSERNAME_K}${\n}
    ${pid2}=  get_acc_id  ${MUSERNAME_K}  
    ${resp}=  Get Account contact information
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['account']}             ${pid2}
    Should Be Equal As Strings  ${resp.json()['primaryPhoneNumber']}  ${MUSERNAME_K}
    Should Be Equal As Strings  ${resp.json()['contactFirstName']}    ${firstname_A}
    Should Be Equal As Strings  ${resp.json()['contactLastName']}     ${lastname_A}
    Should Be Equal As Strings  ${resp.json()['emailVerified']}       ${bool[0]} 
    Should Be Equal As Strings  ${resp.json()['phoneVerified']}       ${bool[1]}
    Set Test Variable  ${country_code}   ${resp.json()['countryCode']} 

    ${firstname2}=  FakerLibrary.first_name
    ${lastname2}=  FakerLibrary.last_name
    ${whatsapp2}=   Evaluate  ${PUSERNAME}+406000224
    Set Test Variable  ${email2}  ${firstname2}${MUSERNAME_K}${C_Email}.${test_mail}
    ${resp}=  Update Account contact information   ${MUSERNAME_K}   ${email2}  ${None}   ${whatsapp2}  ${None}  ${salutation}  ${firstname2}  ${lastname2}  ${country_code}   ${country_code}  ${country_code}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Get Account contact information
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['account']}               ${pid2}
    Should Be Equal As Strings  ${resp.json()['primaryPhoneNumber']}    ${MUSERNAME_K}
    Should Be Equal As Strings  ${resp.json()['contactFirstName']}      ${firstname2}
    Should Be Equal As Strings  ${resp.json()['contactLastName']}       ${lastname2}
    Should Be Equal As Strings  ${resp.json()['salutation']}            ${salutation}
    Should Be Equal As Strings  ${resp.json()['whatsappPhoneNumber']}   ${whatsapp2}
    Should Be Equal As Strings  ${resp.json()['primaryEmail']}          ${email2} 
    Should Be Equal As Strings  ${resp.json()['emailVerified']}         ${bool[0]} 
    Should Be Equal As Strings  ${resp.json()['phoneVerified']}         ${bool[1]} 

    ${resp}=   Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-Update Account Contact information-6
	[Documentation]  Get account contact information with  branch signup through phonenumber and create user

    ${firstname_B}=  FakerLibrary.first_name
    ${lastname_B}=  FakerLibrary.last_name
    ${MUSERNAME_L}=  Evaluate  ${MUSERNAME}+406817222
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname_B}  ${lastname_B}  ${None}  ${domains}  ${sub_domains}  ${MUSERNAME_L}    ${highest_package[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${MUSERNAME_L}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${MUSERNAME_L}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Encrypted Provider Login  ${MUSERNAME_L}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${subdomain}  ${resp.json()['subSector']}
    Set Test Variable  ${pro_id3}  ${resp.json()['id']}
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${MUSERNAME_L}${\n}
    Set Suite Variable  ${MUSERNAME_L}
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${MUSERNAME_L}${\n}
    ${pid4}=  get_acc_id  ${MUSERNAME_L}  
    ${resp}=  Get Account contact information
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['account']}      ${pid4}
    Should Be Equal As Strings  ${resp.json()['primaryPhoneNumber']}  ${MUSERNAME_L}
    Should Be Equal As Strings  ${resp.json()['contactFirstName']}  ${firstname_B}
    Should Be Equal As Strings  ${resp.json()['contactLastName']}  ${lastname_B}
    Should Be Equal As Strings  ${resp.json()['emailVerified']}   ${bool[0]} 
    Should Be Equal As Strings  ${resp.json()['phoneVerified']}   ${bool[1]}
    Set Test Variable  ${country_code}   ${resp.json()['countryCode']} 

    ${iscorp_subdomains}=  get_iscorp_subdomains  1
    Log  ${iscorp_subdomains}
    ${dlen}=  Get Length  ${iscorp_subdomains}
    FOR  ${pos}  IN RANGE  ${dlen}  
        IF  '${iscorp_subdomains[${pos}]['subdomains']}' == '${subdomain}'
            Set Suite Variable  ${sub_domain_id}   ${iscorp_subdomains[0]['subdomainId']}
            Set Suite Variable  ${userSubDomain}  ${iscorp_subdomains[0]['userSubDomain']}
            Exit For Loop
        ELSE
            Continue For Loop
        END
    END

    ${resp}=   Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  View Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Toggle Department Enable
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    END
    
    sleep  2s
    ${resp}=  Get Departments
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}
    ${PUSERNAME_U1}=  Evaluate  ${PUSERNAME}+3466735
    clear_users  ${PUSERNAME_U1}
    ${firstname2}=  FakerLibrary.name
    ${lastname2}=  FakerLibrary.last_name
    ${dob2}=  FakerLibrary.Date
    # ${pin2}=  get_pincode

    # ${resp}=  Get LocationsByPincode     ${pin2}
    FOR    ${i}    IN RANGE    3
        ${pin2}=  get_pincode
        ${kwstatus}  ${resp} = 	Run Keyword And Ignore Error  Get LocationsByPincode  ${pin2}
        IF    '${kwstatus}' == 'FAIL'
                Continue For Loop
        ELSE IF    '${kwstatus}' == 'PASS'
                Exit For Loop
        END
    END
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${city2}   ${resp.json()[0]['PostOffice'][0]['District']}   
    Set Test Variable  ${state2}  ${resp.json()[0]['PostOffice'][0]['State']}      
    Set Test Variable  ${pin2}    ${resp.json()[0]['PostOffice'][0]['Pincode']}    
 
    ${whpnum}=  Evaluate  ${PUSERNAME_U1}+335241
    ${tlgnum}=  Evaluate  ${PUSERNAME_U1}+335142

    ${resp}=  Create User  ${firstname2}  ${lastname2}  ${dob2}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U1}.${test_mail}   ${userType[0]}  ${pin2}  ${countryCodes[0]}  ${PUSERNAME_U1}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${countryCodes[0]}  ${whpnum}  ${countryCodes[0]}  ${tlgnum}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${u_id}  ${resp.json()}

    ${resp}=  Get User By Id  ${u_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${u_id}  firstName=${firstname2}  lastName=${lastname2}   mobileNo=${PUSERNAME_U1}  dob=${dob2}  gender=${Genderlist[0]}  userType=${userType[0]}  status=ACTIVE  email=${P_Email}${PUSERNAME_U1}.${test_mail}   deptId=${dep_id}  subdomain=${userSubDomain}

    ${resp}=  Get Account contact information
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['account']}              ${pid4}
    Should Be Equal As Strings  ${resp.json()['primaryPhoneNumber']}  ${MUSERNAME_L}
    Should Be Equal As Strings  ${resp.json()['contactFirstName']}  ${firstname_B}
    Should Be Equal As Strings  ${resp.json()['contactLastName']}   ${lastname_B}
    Should Be Equal As Strings  ${resp.json()['emailVerified']}     ${bool[0]} 
    Should Be Equal As Strings  ${resp.json()['phoneVerified']}     ${bool[1]}

    ${resp}=  Get User
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable   ${u_id}   ${resp.json()[0]['id']}

    ${resp}=  Get Notification Settings of User  ${u_id}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    comment   WAITLISTADD
    Should Be Equal As Strings  ${resp.json()[0]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['eventType']}   ${EventType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['email'][0]}    ${P_Email}${PUSERNAME_U1}.${test_mail}
    Should Be Equal As Strings  ${resp.json()[0]['sms'][0]['number']}           ${PUSERNAME_U1} 
    Should Be Equal As Strings  ${resp.json()[0]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]['number']}       ${PUSERNAME_U1} 
    Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[0]['sms'][0]}      ${PUSERNAME_U1}
    # Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]}  ${PUSERNAME_U1}
    comment   WAITLIST-CANCEL
    Should Be Equal As Strings  ${resp.json()[1]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[1]['eventType']}     ${EventType[1]}
    Should Be Equal As Strings  ${resp.json()[1]['email'][0]}      ${P_Email}${PUSERNAME_U1}.${test_mail}
    Should Be Equal As Strings  ${resp.json()[1]['sms'][0]['number']}           ${PUSERNAME_U1} 
    Should Be Equal As Strings  ${resp.json()[1]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]['number']}       ${PUSERNAME_U1} 
    Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[1]['sms'][0]}        ${PUSERNAME_U1}
    # Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]}    ${PUSERNAME_U1}
    comment   APPOINTMENTADD
    Should Be Equal As Strings  ${resp.json()[2]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[2]['eventType']}    ${EventType[7]}
    Should Be Equal As Strings  ${resp.json()[2]['email'][0]}     ${P_Email}${PUSERNAME_U1}.${test_mail}
    Should Be Equal As Strings  ${resp.json()[2]['sms'][0]['number']}           ${PUSERNAME_U1} 
    Should Be Equal As Strings  ${resp.json()[2]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]['number']}       ${PUSERNAME_U1} 
    Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[2]['sms'][0]}       ${PUSERNAME_U1}
    # Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]}   ${PUSERNAME_U1}
    comment   APPOINTMENT-CANCEL
    Should Be Equal As Strings  ${resp.json()[3]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[3]['eventType']}     ${EventType[8]}
    Should Be Equal As Strings  ${resp.json()[3]['email'][0]}      ${P_Email}${PUSERNAME_U1}.${test_mail}
    Should Be Equal As Strings  ${resp.json()[3]['sms'][0]['number']}           ${PUSERNAME_U1} 
    Should Be Equal As Strings  ${resp.json()[3]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]['number']}       ${PUSERNAME_U1} 
    Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[3]['sms'][0]}        ${PUSERNAME_U1}
    # Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]}    ${PUSERNAME_U1}
    
    ${firstname3}=  FakerLibrary.first_name
    ${lastname3}=  FakerLibrary.last_name
    ${whatsapp3}=   Evaluate  ${PUSERNAME}+407000225
    Set Test Variable  ${email2}  ${firstname3}${MUSERNAME_L}${C_Email}.${test_mail}
    ${resp}=  Update Account contact information   ${PUSERNAME_U1}   ${email2}  ${None}   ${whatsapp3}  ${None}  ${salutation}  ${firstname3}  ${lastname3}  ${country_code}  ${country_code}  ${country_code}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Get Account contact information
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['account']}               ${pid4}
    Should Be Equal As Strings  ${resp.json()['primaryPhoneNumber']}    ${PUSERNAME_U1}
    Should Be Equal As Strings  ${resp.json()['contactFirstName']}      ${firstname3}
    Should Be Equal As Strings  ${resp.json()['contactLastName']}       ${lastname3}
    Should Be Equal As Strings  ${resp.json()['salutation']}            ${salutation}
    Should Be Equal As Strings  ${resp.json()['whatsappPhoneNumber']}   ${whatsapp3}
    Should Be Equal As Strings  ${resp.json()['primaryEmail']}      ${email2} 
    Should Be Equal As Strings  ${resp.json()['emailVerified']}     ${bool[0]} 
    Should Be Equal As Strings  ${resp.json()['phoneVerified']}     ${bool[0]} 


JD-TC-Update Account Contact information-7
    [Documentation]  Update account contact information of a existing provider with already used email
    ${resp}=  Encrypted Provider Login  ${PUSERNAME5}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable    ${first-name}    ${resp.json()['firstName']}  
    Set Test Variable    ${last-name}     ${resp.json()['lastName']} 
    ${pid3}=  get_acc_id  ${PUSERNAME5}  
    ${resp}=  Get Account contact information
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['account']}            ${pid3}
    Should Be Equal As Strings  ${resp.json()['primaryPhoneNumber']}  ${PUSERNAME5}
    Should Be Equal As Strings  ${resp.json()['contactFirstName']}   ${first-name}
    Should Be Equal As Strings  ${resp.json()['contactLastName']}    ${last-name}
    Should Be Equal As Strings  ${resp.json()['emailVerified']}      ${bool[0]} 
    Should Be Equal As Strings  ${resp.json()['phoneVerified']}      ${bool[1]} 
    Set Test Variable  ${country_code}   ${resp.json()['countryCode']} 

    ${firstname3}=  FakerLibrary.first_name
    ${lastname3}=  FakerLibrary.last_name
    ${whatsapp3}=   Evaluate  ${PUSERNAME}+406000225
    # Set Test Variable  ${email2}  ${firstname1}${MUSERNAME_K}${C_Email}.${test_mail}
    ${resp}=  Update Account contact information   ${PUSERNAME5}   ${email1}  ${None}   ${whatsapp3}  ${None}  ${salutation}  ${firstname3}  ${lastname3}   ${country_code}  ${country_code}  ${country_code}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Get Account contact information
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['account']}               ${pid3}
    Should Be Equal As Strings  ${resp.json()['primaryPhoneNumber']}    ${PUSERNAME5}
    Should Be Equal As Strings  ${resp.json()['contactFirstName']}      ${firstname3}
    Should Be Equal As Strings  ${resp.json()['contactLastName']}       ${lastname3}
    Should Be Equal As Strings  ${resp.json()['salutation']}            ${salutation}
    Should Be Equal As Strings  ${resp.json()['whatsappPhoneNumber']}   ${whatsapp3}
    Should Be Equal As Strings  ${resp.json()['primaryEmail']}      ${email1} 
    Should Be Equal As Strings  ${resp.json()['emailVerified']}     ${bool[0]} 
    Should Be Equal As Strings  ${resp.json()['phoneVerified']}     ${bool[1]} 


JD-TC-Update Account Contact information-8
	[Documentation]  Update Account Contact information using email of another provider(verified email)
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME10}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable    ${first-name}    ${resp.json()['firstName']}  
    Set Test Variable    ${last-name}     ${resp.json()['lastName']} 
    ${pid3}=  get_acc_id  ${PUSERNAME10}  
    ${resp}=  Get Account contact information
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['account']}             ${pid3}
    Should Be Equal As Strings  ${resp.json()['primaryPhoneNumber']}  ${PUSERNAME10}
    Should Be Equal As Strings  ${resp.json()['contactFirstName']}  ${first-name}
    Should Be Equal As Strings  ${resp.json()['contactLastName']}  ${last-name}
    Should Be Equal As Strings  ${resp.json()['emailVerified']}    ${bool[0]} 
    Should Be Equal As Strings  ${resp.json()['phoneVerified']}    ${bool[1]} 
    Set Test Variable  ${country_code}   ${resp.json()['countryCode']} 

    ${firstname3}=  FakerLibrary.first_name
    ${lastname3}=  FakerLibrary.last_name
    ${resp}=  Update Account contact information   ${PUSERNAME10}   ${e-mail}  ${None}   ${None}  ${None}  ${salutation}  ${firstname3}  ${lastname3}   ${country_code}  ${country_code}  ${country_code}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Get Account contact information
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['account']}            ${pid3}
    Should Be Equal As Strings  ${resp.json()['primaryPhoneNumber']}  ${PUSERNAME10}
    Should Be Equal As Strings  ${resp.json()['contactFirstName']}  ${firstname3}
    Should Be Equal As Strings  ${resp.json()['contactLastName']}  ${lastname3}
    Should Be Equal As Strings  ${resp.json()['salutation']}       ${salutation}
    Should Be Equal As Strings  ${resp.json()['primaryEmail']}     ${e-mail} 
    Should Be Equal As Strings  ${resp.json()['emailVerified']}    ${bool[0]} 
    Should Be Equal As Strings  ${resp.json()['phoneVerified']}    ${bool[1]} 

JD-TC-Update Account Contact information-9
	[Documentation]  Update Account Contact information using whatsapp number of another provider
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME9}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable    ${first-name}    ${resp.json()['firstName']}  
    Set Test Variable    ${last-name}     ${resp.json()['lastName']} 
    ${pid3}=  get_acc_id  ${PUSERNAME9}  
    ${resp}=  Get Account contact information
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['account']}             ${pid3}
    Should Be Equal As Strings  ${resp.json()['primaryPhoneNumber']}  ${PUSERNAME9}
    Should Be Equal As Strings  ${resp.json()['contactFirstName']}    ${first-name}
    Should Be Equal As Strings  ${resp.json()['contactLastName']}    ${last-name}
    Should Be Equal As Strings  ${resp.json()['emailVerified']}      ${bool[0]} 
    Should Be Equal As Strings  ${resp.json()['phoneVerified']}      ${bool[1]} 
    Set Test Variable  ${country_code}   ${resp.json()['countryCode']} 

    ${firstname3}=  FakerLibrary.first_name
    ${lastname3}=  FakerLibrary.last_name
    Set Test Variable  ${email}  ${firstname3}${PUSERNAME9}${C_Email}.${test_mail}
    ${resp}=  Update Account contact information   ${PUSERNAME9}   ${email}  ${None}   ${whatsapp1}  ${None}  ${salutation}  ${firstname3}  ${lastname3}  ${country_code}   ${country_code}  ${country_code} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Get Account contact information
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['account']}               ${pid3}
    Should Be Equal As Strings  ${resp.json()['primaryPhoneNumber']}    ${PUSERNAME9}
    Should Be Equal As Strings  ${resp.json()['contactFirstName']}      ${firstname3}
    Should Be Equal As Strings  ${resp.json()['contactLastName']}       ${lastname3}
    Should Be Equal As Strings  ${resp.json()['salutation']}            ${salutation}
    Should Be Equal As Strings  ${resp.json()['whatsappPhoneNumber']}   ${whatsapp1}
    Should Be Equal As Strings  ${resp.json()['primaryEmail']}       ${email} 
    Should Be Equal As Strings  ${resp.json()['emailVerified']}      ${bool[0]} 
    Should Be Equal As Strings  ${resp.json()['phoneVerified']}      ${bool[1]} 


JD-TC-Update Account Contact information-10
	[Documentation]  Update Account Contact information using secondary phone number of another provider
    ${resp}=  Encrypted Provider Login  ${PUSERNAME6}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable    ${first-name}    ${resp.json()['firstName']}  
    Set Test Variable    ${last-name}     ${resp.json()['lastName']} 
    ${pid3}=  get_acc_id  ${PUSERNAME6}  
    ${resp}=  Get Account contact information
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['account']}             ${pid3}
    Should Be Equal As Strings  ${resp.json()['primaryPhoneNumber']}  ${PUSERNAME6}
    Should Be Equal As Strings  ${resp.json()['contactFirstName']}  ${first-name}
    Should Be Equal As Strings  ${resp.json()['contactLastName']}   ${last-name}
    Should Be Equal As Strings  ${resp.json()['emailVerified']}     ${bool[0]} 
    Should Be Equal As Strings  ${resp.json()['phoneVerified']}     ${bool[1]} 
    Set Test Variable  ${country_code}   ${resp.json()['countryCode']} 

    ${firstname3}=  FakerLibrary.first_name
    ${lastname3}=  FakerLibrary.last_name
    Set Test Variable  ${email}  ${firstname3}${PUSERNAME6}${C_Email}.${test_mail}
    ${resp}=  Update Account contact information   ${PUSERNAME6}   ${email}  ${secondary-phone}   ${None}  ${None}  ${salutation}  ${firstname3}  ${lastname3}   ${country_code}  ${country_code}  ${country_code}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Get Account contact information
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['account']}             ${pid3}
    Should Be Equal As Strings  ${resp.json()['primaryPhoneNumber']}  ${PUSERNAME6}
    Should Be Equal As Strings  ${resp.json()['contactFirstName']}  ${firstname3}
    Should Be Equal As Strings  ${resp.json()['contactLastName']}   ${lastname3}
    Should Be Equal As Strings  ${resp.json()['salutation']}        ${salutation}
    Should Be Equal As Strings  ${resp.json()['primaryEmail']}      ${email} 
    Should Be Equal As Strings  ${resp.json()['emailVerified']}     ${bool[0]} 
    Should Be Equal As Strings  ${resp.json()['phoneVerified']}     ${bool[1]} 


JD-TC-Update Account Contact information-11
	[Documentation]  Update Account Contact information using secondary email of another provider
    ${resp}=  Encrypted Provider Login  ${PUSERNAME7}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable    ${first-name}    ${resp.json()['firstName']}  
    Set Test Variable    ${last-name}     ${resp.json()['lastName']} 
    ${pid3}=  get_acc_id  ${PUSERNAME7}  
    ${resp}=  Get Account contact information
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['account']}             ${pid3}
    Should Be Equal As Strings  ${resp.json()['primaryPhoneNumber']}  ${PUSERNAME7}
    Should Be Equal As Strings  ${resp.json()['contactFirstName']}    ${first-name}
    Should Be Equal As Strings  ${resp.json()['contactLastName']}     ${last-name}
    Should Be Equal As Strings  ${resp.json()['emailVerified']}       ${bool[0]} 
    Should Be Equal As Strings  ${resp.json()['phoneVerified']}       ${bool[1]} 
    Set Test Variable  ${country_code}   ${resp.json()['countryCode']} 

    ${firstname3}=  FakerLibrary.first_name
    ${lastname3}=  FakerLibrary.last_name
    Set Test Variable  ${email}  ${firstname3}${PUSERNAME7}${C_Email}.${test_mail}
    ${resp}=  Update Account contact information   ${PUSERNAME7}   ${email}  ${None}   ${None}  ${email0}  ${salutation}  ${firstname3}  ${lastname3}   ${country_code}  ${country_code}  ${country_code}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Get Account contact information
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['account']}             ${pid3}
    Should Be Equal As Strings  ${resp.json()['primaryPhoneNumber']}  ${PUSERNAME7}
    Should Be Equal As Strings  ${resp.json()['contactFirstName']}  ${firstname3}
    Should Be Equal As Strings  ${resp.json()['contactLastName']}  ${lastname3}
    Should Be Equal As Strings  ${resp.json()['salutation']}      ${salutation}
    Should Be Equal As Strings  ${resp.json()['primaryEmail']}   ${email} 
    Should Be Equal As Strings  ${resp.json()['emailVerified']}  ${bool[0]} 
    Should Be Equal As Strings  ${resp.json()['phoneVerified']}  ${bool[1]} 

JD-TC-Update Account Contact information-12
	[Documentation]  Update Account Contact information using firstname and lastname of another provider
    ${resp}=  Encrypted Provider Login  ${PUSERNAME11}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable    ${first-name1}    ${resp.json()['firstName']}  
    Set Test Variable    ${last-name1}     ${resp.json()['lastName']} 
    ${pid3}=  get_acc_id  ${PUSERNAME11}  
    ${resp}=  Get Account contact information
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['account']}             ${pid3}
    Should Be Equal As Strings  ${resp.json()['primaryPhoneNumber']}  ${PUSERNAME11}
    Should Be Equal As Strings  ${resp.json()['contactFirstName']}  ${first-name1}
    Should Be Equal As Strings  ${resp.json()['contactLastName']}   ${last-name1}
    Should Be Equal As Strings  ${resp.json()['emailVerified']}     ${bool[0]} 
    Should Be Equal As Strings  ${resp.json()['phoneVerified']}     ${bool[1]} 
    Set Test Variable  ${country_code}   ${resp.json()['countryCode']} 

    Set Test Variable  ${email}  ${last-name1}${PUSERNAME11}${C_Email}.${test_mail}
    ${resp}=  Update Account contact information   ${PUSERNAME11}   ${None}  ${None}   ${None}  ${None}  ${salutation}  ${firstname}  ${lastname}   ${country_code}  ${country_code}  ${country_code}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Get Account contact information
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['account']}             ${pid3}
    Should Be Equal As Strings  ${resp.json()['primaryPhoneNumber']}  ${PUSERNAME11}
    Should Be Equal As Strings  ${resp.json()['contactFirstName']}  ${firstname}
    Should Be Equal As Strings  ${resp.json()['contactLastName']}   ${lastname}
    Should Be Equal As Strings  ${resp.json()['salutation']}        ${salutation}
    # Should Be Equal As Strings  ${resp.json()['primaryEmail']}  ${email}
    Should Be Equal As Strings  ${resp.json()['emailVerified']}    ${bool[0]} 
    Should Be Equal As Strings  ${resp.json()['phoneVerified']}    ${bool[1]} 

JD-TC-Update Account Contact information-13
	[Documentation]  Get account contact information of a provider and then do consumer signup with same number and update consumer details and check new change in provider side
    
    ${domresp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${domresp.status_code}  200
    ${len}=  Get Length  ${domresp.json()}
    ${len}=  Evaluate  ${len}-1
    ${PUSERNAME_N}=  Evaluate  ${PUSERNAME}+406380222
    Set Test Variable  ${d1}  ${domresp.json()[${len}]['domain']}    
    Set Test Variable  ${sd}  ${domresp.json()[${len}]['subDomains'][0]['subDomain']} 
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${d1}  ${sd}  ${PUSERNAME_N}   ${highest_package[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAME_N}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAME_N}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_N}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${pro_idN}  ${resp.json()['id']}
    Set Test Variable  ${PUSERNAME_N}
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERNAME_N}${\n}  
    
    Set Test Variable    ${first-name}    ${resp.json()['firstName']}  
    Set Test Variable    ${last-name}     ${resp.json()['lastName']} 
    ${pid4}=  get_acc_id  ${PUSERNAME_N}  
    ${resp}=  Get Account contact information
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['account']}              ${pid4}
    Should Be Equal As Strings  ${resp.json()['primaryPhoneNumber']}   ${PUSERNAME_N}
    Should Be Equal As Strings  ${resp.json()['contactFirstName']}     ${first-name}
    Should Be Equal As Strings  ${resp.json()['contactLastName']}      ${last-name}
    Should Be Equal As Strings  ${resp.json()['emailVerified']}        ${bool[0]} 
    Should Be Equal As Strings  ${resp.json()['phoneVerified']}         ${bool[1]} 
    Set Suite Variable  ${country_code}   ${resp.json()['countryCode']} 
    
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}=  Random Element    ${Genderlist}
    ${address}=  FakerLibrary.Address
    ${alternativeNo}=  Evaluate  ${PUSERNAME23}+76068
    Set Test Variable  ${email}  ${firstname}${PUSERNAME_N}${C_Email}.${test_mail}
    ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${PUSERNAME_N}   ${alternativeNo}  ${dob}  ${gender}   ${EMPTY}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Activation  ${PUSERNAME_N}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Set Credential  ${PUSERNAME_N}  ${PASSWORD}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Login  ${PUSERNAME_N}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${newNo}=  Evaluate  ${PUSERNAME}+77898
    ${resp}=  Update Consumer Profile With Emailid    ${firstname}  ${lastname}  ${address}   ${dob}  ${gender}  ${email}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Send Verify Login Consumer   ${newNo}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Verify Login Consumer   ${newNo}  5
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${newNo}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Consumer By Id  ${newNo}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_N}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${pid5}=  get_acc_id  ${PUSERNAME_N} 

    ${resp}=  Get Account contact information
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['account']}              ${pid5}
    Should Be Equal As Strings  ${resp.json()['primaryPhoneNumber']}   ${newNo}
    Should Be Equal As Strings  ${resp.json()['contactFirstName']}     ${firstname}
    Should Be Equal As Strings  ${resp.json()['contactLastName']}      ${lastname}
    Should Be Equal As Strings  ${resp.json()['primaryEmail']}         ${email}
    Should Be Equal As Strings  ${resp.json()['emailVerified']}        ${bool[0]} 
    Should Be Equal As Strings  ${resp.json()['phoneVerified']}        ${bool[1]} 

    
JD-TC-Update Account Contact information-14
	[Documentation]  Update account contact information with  signup through email and update primary email and secondary email at same time
    ${domresp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${domresp.status_code}  200
    ${len}=  Get Length  ${domresp.json()}
    ${len}=  Evaluate  ${len}-1
    ${PUSERNAME_C}=  Evaluate  ${PUSERNAME}+408118222
    Set Test Variable  ${d1}  ${domresp.json()[${len}]['domain']}    
    Set Test Variable  ${sd}  ${domresp.json()[${len}]['subDomains'][0]['subDomain']} 
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${highest_package}=  get_highest_license_pkg
    Set Test Variable  ${e-mail}  ${firstname}${PUSERNAME_C}${C_Email}.${test_mail}
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${e-mail}  ${d1}  ${sd}  ${PUSERNAME_C}   ${highest_package[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${e-mail}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${e-mail}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_C}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${pro_id}  ${decrypted_data['id']}
    # Set Test Variable  ${pro_id}  ${resp.json()['id']}
    Set Test Variable  ${PUSERNAME_C}
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERNAME_C}${\n}  
    ${pid}=  get_acc_id  ${PUSERNAME_C}
    ${resp}=  Get Provider Details    ${pro_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['basicInfo']['id']}              ${pro_id}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['firstName']}       ${firstname}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['lastName']}        ${lastname}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['mobile']}          ${PUSERNAME_C}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['email']}           ${e-mail}
    # Should Be Equal As Strings  ${resp.json()['basicInfo']['emailVerified']}   ${bool[1]} 
    # Should Be Equal As Strings  ${resp.json()['basicInfo']['phoneVerified']}   ${bool[0]} 
   
    ${firstname1}=  FakerLibrary.first_name
    ${lastname1}=  FakerLibrary.last_name
    ${resp}=  Update Account contact information   ${PUSERNAME_C}   ${e-mail}  ${None}   ${None}  ${e-mail}  ${salutation}  ${firstname1}  ${lastname1}   ${country_code}  ${country_code}  ${country_code}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Get Account contact information
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['account']}             ${pid}
    Should Be Equal As Strings  ${resp.json()['primaryPhoneNumber']}  ${PUSERNAME_C}
    Should Be Equal As Strings  ${resp.json()['contactFirstName']}  ${firstname1}
    Should Be Equal As Strings  ${resp.json()['contactLastName']}  ${lastname1}
    Should Be Equal As Strings  ${resp.json()['primaryEmail']}     ${e-mail}
    Should Be Equal As Strings  ${resp.json()['secondaryEmail']}  ${e-mail}
    Should Be Equal As Strings  ${resp.json()['emailVerified']}   ${bool[1]} 
    Should Be Equal As Strings  ${resp.json()['phoneVerified']}   ${bool[0]} 


    ${firstname2}=  FakerLibrary.first_name
    ${lastname2}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}=  Random Element    ${Genderlist}
    Set Test Variable  ${email_n}  ${firstname2}${PUSERNAME0}${C_Email}.${test_mail}
    ${resp}=   Update Service Provider With Emailid    ${pro_id}  ${firstName2}  ${lastName2}  ${gender}  ${dob}  ${email_n}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Provider Details    ${pro_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['basicInfo']['id']}              ${pro_id}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['firstName']}       ${firstname2}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['lastName']}        ${lastname2}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['mobile']}          ${PUSERNAME_C}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['email']}           ${email_n}
    # Should Be Equal As Strings  ${resp.json()['basicInfo']['emailVerified']}   ${bool[1]} 
    # Should Be Equal As Strings  ${resp.json()['basicInfo']['phoneVerified']}   ${bool[0]} 

    ${resp}=  Get Account contact information
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['account']}             ${pid}
    Should Be Equal As Strings  ${resp.json()['primaryPhoneNumber']}  ${PUSERNAME_C}
    Should Be Equal As Strings  ${resp.json()['contactFirstName']}   ${firstname2}
    Should Be Equal As Strings  ${resp.json()['contactLastName']}    ${lastname2}
    Should Be Equal As Strings  ${resp.json()['primaryEmail']}       ${email_n}
    Should Be Equal As Strings  ${resp.json()['secondaryEmail']}     ${email_n}
    Should Be Equal As Strings  ${resp.json()['emailVerified']}      ${bool[0]} 
    Should Be Equal As Strings  ${resp.json()['phoneVerified']}      ${bool[0]} 



JD-TC-Update Account Contact information-15
	[Documentation]  Update account contact information with  signup through primarynumber and update primary number and secondary number at same time
    ${domresp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${domresp.status_code}  200
    ${len}=  Get Length  ${domresp.json()}
    ${len}=  Evaluate  ${len}-1
    ${PUSERNAME0}=  Evaluate  ${PUSERNAME}+406011222
    Set Test Variable  ${d1}  ${domresp.json()[${len}]['domain']}    
    Set Test Variable  ${sd}  ${domresp.json()[${len}]['subDomains'][0]['subDomain']} 
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${d1}  ${sd}  ${PUSERNAME0}   ${highest_package[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAME0}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAME0}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Encrypted Provider Login  ${PUSERNAME0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${pro_id0}  ${decrypted_data['id']}
    # Set Test Variable  ${pro_id0}  ${resp.json()['id']}
    Set Suite Variable  ${PUSERNAME0}
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERNAME0}${\n}  
    ${pid}=  get_acc_id  ${PUSERNAME0}
    ${resp}=  Get Provider Details    ${pro_id0} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['basicInfo']['id']}              ${pro_id0}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['firstName']}       ${firstname}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['lastName']}        ${lastname}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['mobile']}          ${PUSERNAME0}
    # Should Be Equal As Strings  ${resp.json()['basicInfo']['emailVerified']}   ${bool[0]} 
    # Should Be Equal As Strings  ${resp.json()['basicInfo']['phoneVerified']}   ${bool[1]} 

    ${firstname1}=  FakerLibrary.first_name
    ${lastname1}=  FakerLibrary.last_name
    Set Test Variable  ${email}  ${firstname1}${PUSERNAME0}${C_Email}.${test_mail}
    ${resp}=  Update Account contact information   ${PUSERNAME0}   ${email}  ${PUSERNAME0}   ${None}  ${email}  ${salutation}  ${firstname1}  ${lastname1}   ${country_code}  ${country_code}  ${country_code}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Get Account contact information
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['account']}               ${pid}
    Should Be Equal As Strings  ${resp.json()['primaryPhoneNumber']}    ${PUSERNAME0}
    Should Be Equal As Strings  ${resp.json()['contactFirstName']}      ${firstname1}
    Should Be Equal As Strings  ${resp.json()['contactLastName']}       ${lastname1}
    Should Be Equal As Strings  ${resp.json()['primaryEmail']}          ${email}
    Should Be Equal As Strings  ${resp.json()['secondaryEmail']}        ${email}
    Should Be Equal As Strings  ${resp.json()['secondaryPhoneNumber']}  ${PUSERNAME0}
    Should Be Equal As Strings  ${resp.json()['emailVerified']}         ${bool[0]} 
    Should Be Equal As Strings  ${resp.json()['phoneVerified']}         ${bool[1]} 

    ${firstname2}=  FakerLibrary.first_name
    ${lastname2}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}=  Random Element    ${Genderlist}
    Set Test Variable  ${email_n}  ${firstname2}${PUSERNAME0}${C_Email}.${test_mail}
    ${resp}=   Update Service Provider With Emailid    ${pro_id0}  ${firstName2}  ${lastName2}  ${gender}  ${dob}  ${email_n}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${PUSERNAME_1}=  Evaluate  ${PUSERNAME}+405655123
    ${resp}=  Send Verify Login   ${PUSERNAME_1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Verify Login   ${PUSERNAME_1}  4
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  Get Provider Details    ${pro_id0} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['basicInfo']['id']}              ${pro_id0}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['firstName']}       ${firstname2}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['lastName']}        ${lastname2}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['mobile']}          ${PUSERNAME0}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['email']}           ${email_n}
    # Should Be Equal As Strings  ${resp.json()['basicInfo']['emailVerified']}   ${bool[1]} 
    # Should Be Equal As Strings  ${resp.json()['basicInfo']['phoneVerified']}   ${bool[1]} 

    ${resp}=  Get Account contact information
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['account']}               ${pid}
    Should Be Equal As Strings  ${resp.json()['primaryPhoneNumber']}    ${PUSERNAME_1}
    Should Be Equal As Strings  ${resp.json()['contactFirstName']}      ${firstname2}
    Should Be Equal As Strings  ${resp.json()['contactLastName']}       ${lastname2}
    Should Be Equal As Strings  ${resp.json()['primaryEmail']}          ${email}
    Should Be Equal As Strings  ${resp.json()['secondaryEmail']}        ${email}
    Should Be Equal As Strings  ${resp.json()['secondaryPhoneNumber']}  ${PUSERNAME_1}
    Should Be Equal As Strings  ${resp.json()['emailVerified']}         ${bool[0]} 
    Should Be Equal As Strings  ${resp.json()['phoneVerified']}         ${bool[1]} 

    ${resp}=   Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    comment   LICENSE
    Should Be Equal As Strings  ${resp.json()[5]['resourceType']}  ${NotificationResourceType[2]}
    Should Be Equal As Strings  ${resp.json()[5]['eventType']}     ${EventType[9]}
    Should Be Equal As Strings  ${resp.json()[5]['email'][0]}      ${email}
    Should Be Equal As Strings  ${resp.json()[5]['sms'][0]['number']}           ${PUSERNAME_1} 
    Should Be Equal As Strings  ${resp.json()[5]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[5]['pushMsg'][0]['number']}       ${PUSERNAME_1} 
    Should Be Equal As Strings  ${resp.json()[5]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[5]['sms'][0]}        ${PUSERNAME_1}
    # Should Be Equal As Strings  ${resp.json()[5]['pushMsg'][0]}    ${PUSERNAME_1}

JD-TC-Update Account Contact information-UH1
    [Documentation]  Update a account contact information using consumer login
    ${resp}=  ConsumerLogin  ${CUSERNAME2}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${firstname4}=  FakerLibrary.first_name
    ${lastname4}=  FakerLibrary.last_name
    ${resp}=  Update Account contact information   ${CUSERNAME2}   ${email1}  ${None}   ${None}  ${None}  ${salutation}  ${firstname4}  ${lastname4}   ${country_code}  ${country_code}  ${country_code}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings   ${resp.json()}   ${LOGIN_NO_ACCESS_FOR_URL}
    
JD-TC-Update Account Contact information-UH2
    [Documentation]  Update  account contact information without login
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${resp}=  Update Account contact information   ${PUSERNAME5}   ${email1}  ${None}   ${None}  ${None}  ${salutation}  ${firstname}  ${lastname}   ${country_code}  ${country_code}  ${country_code}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"
     

JD-TC-Update Account Contact information-UH3
    [Documentation]  Update Account Contact information using primary mob no of another provider
    ${domresp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${domresp.status_code}  200
    ${len}=  Get Length  ${domresp.json()}
    ${len}=  Evaluate  ${len}-1
    ${PUSERNAME5}=  Evaluate  ${PUSERNAME}+4080340222
    Set Test Variable  ${d1}  ${domresp.json()[${len}]['domain']}    
    Set Test Variable  ${sd}  ${domresp.json()[${len}]['subDomains'][0]['subDomain']} 
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${d1}  ${sd}  ${PUSERNAME5}   ${highest_package[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAME5}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAME5}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Encrypted Provider Login  ${PUSERNAME5}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${PUSERNAME5}
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERNAME5}${\n}  
    ${pid5}=  get_acc_id  ${PUSERNAME5}
    ${resp}=  Get Account contact information
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['account']}              ${pid5}
    Should Be Equal As Strings  ${resp.json()['primaryPhoneNumber']}   ${PUSERNAME5}
    Should Be Equal As Strings  ${resp.json()['contactFirstName']}     ${firstname}
    Should Be Equal As Strings  ${resp.json()['contactLastName']}      ${lastname}
    Should Be Equal As Strings  ${resp.json()['emailVerified']}        ${bool[0]} 
    Should Be Equal As Strings  ${resp.json()['phoneVerified']}        ${bool[1]} 

    ${firstname5}=  FakerLibrary.first_name
    ${lastname5}=  FakerLibrary.last_name
    ${whatsapp5}=   Evaluate  ${PUSERNAME}+406054222
    Set Test Variable  ${email}  ${firstname}${PUSERNAME5}${C_Email}.${test_mail}
    ${resp}=  Update Account contact information   ${PUSERNAME}   ${email}  ${None}   ${None}  ${None}  ${salutation}  ${firstname5}  ${lastname5}   ${country_code}  ${country_code}  ${country_code}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${USED_PHONE_NUMBER }"

JD-TC-Update Account Contact information-UH4
    [Documentation]  Update Account Contact information using invalid primary number
    ${domresp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${domresp.status_code}  200
    ${len}=  Get Length  ${domresp.json()}
    ${len}=  Evaluate  ${len}-1
    ${PUSERNAME}=  Evaluate  ${PUSERNAME}+4080361222
    Set Test Variable  ${d1}  ${domresp.json()[${len}]['domain']}    
    Set Test Variable  ${sd}  ${domresp.json()[${len}]['subDomains'][0]['subDomain']} 
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${d1}  ${sd}  ${PUSERNAME}   ${highest_package[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAME}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAME}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Encrypted Provider Login  ${PUSERNAME}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${PUSERNAME}
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERNAME}${\n}  
    ${pid5}=  get_acc_id  ${PUSERNAME}
    ${resp}=  Get Account contact information
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['account']}             ${pid5}
    Should Be Equal As Strings  ${resp.json()['primaryPhoneNumber']}  ${PUSERNAME}
    Should Be Equal As Strings  ${resp.json()['contactFirstName']}  ${firstname}
    Should Be Equal As Strings  ${resp.json()['contactLastName']}   ${lastname}
    Should Be Equal As Strings  ${resp.json()['emailVerified']}     ${bool[0]} 
    Should Be Equal As Strings  ${resp.json()['phoneVerified']}     ${bool[1]} 

    ${firstname5}=  FakerLibrary.first_name
    ${lastname5}=  FakerLibrary.last_name
    Set Test Variable  ${email}  ${firstname}${PUSERNAME}${C_Email}.${test_mail}
    ${PUSERNAME1}=  Evaluate  678954327
    ${resp}=  Update Account contact information   ${PUSERNAME1}   ${email}  ${None}   ${None}  ${None}  ${salutation}  ${firstname5}  ${lastname5}   ${country_code}  ${country_code}  ${country_code}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${INVALID_PHONES}"


JD-TC-Update Account Contact information-UH5
	[Documentation]  Update Account Contact information using invalid whatsapp number
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME12}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable    ${first-name}    ${resp.json()['firstName']}  
    Set Test Variable    ${last-name}     ${resp.json()['lastName']} 
    # ${pid3}=  get_acc_id  ${PUSERNAME12} 
    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${pid3}  ${resp.json()['id']} 
    ${resp}=  Get Account contact information
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['account']}             ${pid3}
    Should Be Equal As Strings  ${resp.json()['primaryPhoneNumber']}  ${PUSERNAME12}
    Should Be Equal As Strings  ${resp.json()['contactFirstName']}  ${first-name}
    Should Be Equal As Strings  ${resp.json()['contactLastName']}   ${last-name}
    Should Be Equal As Strings  ${resp.json()['emailVerified']}     ${bool[0]} 
    Should Be Equal As Strings  ${resp.json()['phoneVerified']}     ${bool[1]} 
    ${firstname3}=  FakerLibrary.first_name
    ${lastname3}=  FakerLibrary.last_name
    Set Test Variable  ${email}  ${firstname3}${PUSERNAME12}${C_Email}.${test_mail}
    ${resp}=  Update Account contact information   ${PUSERNAME12}   ${email}  ${None}   00  ${None}  ${salutation}  ${firstname3}  ${lastname3}   ${country_code}  ${country_code}  ${country_code}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings  "${resp.json()}"  "${INVALID_PHONES}"

JD-TC-Update Account Contact information-UH6
	[Documentation]  Update Account Contact information using without firstname
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME19}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable    ${first-name}    ${resp.json()['firstName']}  
    Set Test Variable    ${last-name}     ${resp.json()['lastName']} 
    ${pid9}=  get_acc_id  ${PUSERNAME19}  
    ${resp}=  Get Account contact information
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['account']}             ${pid9}
    Should Be Equal As Strings  ${resp.json()['primaryPhoneNumber']}  ${PUSERNAME19}
    Should Be Equal As Strings  ${resp.json()['contactFirstName']}  ${first-name}
    Should Be Equal As Strings  ${resp.json()['contactLastName']}   ${last-name}
    Should Be Equal As Strings  ${resp.json()['emailVerified']}     ${bool[0]} 
    Should Be Equal As Strings  ${resp.json()['phoneVerified']}     ${bool[1]} 
    ${lastname3}=  FakerLibrary.last_name
    Set Test Variable  ${email}  ${lastname3}${PUSERNAME19}${C_Email}.${test_mail}
    ${resp}=  Update Account contact information   ${PUSERNAME19}   ${email}  ${None}   ${None}  ${None}  ${salutation}  ${None}  ${lastname3}   ${country_code}  ${country_code}  ${country_code}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings  "${resp.json()}"  "${CONTACT_FIRST_NAME}"














***comment***
JD-TC-Update Account Contact information-3
	[Documentation]  Update account contact information with  signup through primaryphonenumber(update basic information)then update provider details with email as null
    ${domresp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${domresp.status_code}  200
    ${len}=  Get Length  ${domresp.json()}
    ${len}=  Evaluate  ${len}-1
    ${PUSERNAME0}=  Evaluate  ${PUSERNAME}+406718222
    Set Test Variable  ${d1}  ${domresp.json()[${len}]['domain']}    
    Set Test Variable  ${sd}  ${domresp.json()[${len}]['subDomains'][0]['subDomain']} 
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${d1}  ${sd}  ${PUSERNAME0}   ${highest_package[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAME0}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAME0}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Encrypted Provider Login  ${PUSERNAME0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${pro_id0}  ${decrypted_data['id']}
    # Set Test Variable  ${pro_id0}  ${resp.json()['id']}
    Set Suite Variable  ${PUSERNAME0}
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERNAME0}${\n}  
    ${pid}=  get_acc_id  ${PUSERNAME0}
    ${resp}=  Get Provider Details    ${pro_id0} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['basicInfo']['id']}   ${pro_id0}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['firstName']}   ${firstname}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['lastName']}   ${lastname}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['mobile']}   ${PUSERNAME0}
    # Should Be Equal As Strings  ${resp.json()['basicInfo']['emailVerified']}   ${bool[0]} 
    # Should Be Equal As Strings  ${resp.json()['basicInfo']['phoneVerified']}   ${bool[1]} 

    ${resp}=   Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    comment   WAITLISTADD
    Should Be Equal As Strings  ${resp.json()[0]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['eventType']}  ${EventType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['email']}  []
    Should Be Equal As Strings  ${resp.json()[0]['sms'][0]}  ${PUSERNAME0}
    Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]}  ${PUSERNAME0}
    comment   WAITLIST-CANCEL
    Should Be Equal As Strings  ${resp.json()[1]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[1]['eventType']}  ${EventType[1]}
    Should Be Equal As Strings  ${resp.json()[1]['email']}  []
    Should Be Equal As Strings  ${resp.json()[1]['sms'][0]}  ${PUSERNAME0}
    Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]}  ${PUSERNAME0}
    comment   APPOINTMENTADD
    Should Be Equal As Strings  ${resp.json()[2]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[2]['eventType']}  ${EventType[7]}
    Should Be Equal As Strings  ${resp.json()[2]['email']}  []
    Should Be Equal As Strings  ${resp.json()[2]['sms'][0]}  ${PUSERNAME0}
    Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]}  ${PUSERNAME0}
    comment   APPOINTMENT-CANCEL
    Should Be Equal As Strings  ${resp.json()[3]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[3]['eventType']}  ${EventType[8]}
    Should Be Equal As Strings  ${resp.json()[3]['email']}  []
    Should Be Equal As Strings  ${resp.json()[3]['sms'][0]}  ${PUSERNAME0}
    Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]}  ${PUSERNAME0}
    comment   LICENSE
    Should Be Equal As Strings  ${resp.json()[4]['resourceType']}  ${NotificationResourceType[2]}
    Should Be Equal As Strings  ${resp.json()[4]['eventType']}  ${EventType[9]}
    Should Be Equal As Strings  ${resp.json()[4]['email']}  []
    Should Be Equal As Strings  ${resp.json()[4]['sms'][0]}  ${PUSERNAME0}
    Should Be Equal As Strings  ${resp.json()[4]['pushMsg'][0]}  ${PUSERNAME0}

    ${resp}=  Get Account contact information
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['account']}      ${pid}
    Should Be Equal As Strings  ${resp.json()['primaryPhoneNumber']}  ${PUSERNAME0}
    Should Be Equal As Strings  ${resp.json()['contactFirstName']}  ${firstname}
    Should Be Equal As Strings  ${resp.json()['contactLastName']}  ${lastname}
    Should Be Equal As Strings  ${resp.json()['emailVerified']}  ${bool[0]} 
    Should Be Equal As Strings  ${resp.json()['phoneVerified']}  ${bool[1]} 

    ${firstname1}=  FakerLibrary.first_name
    ${lastname1}=  FakerLibrary.last_name
    ${whatsapp1}=   Evaluate  ${PUSERNAME}+406100222
    ${secondary-phone}=  Evaluate  ${PUSERNAME}+406000223
    Set Test Variable  ${email}  ${firstname}${PUSERNAME0}${C_Email}.${test_mail}
    Set Suite Variable  ${email0}  ${firstname1}${PUSERNAME0}${C_Email}.${test_mail}
    ${resp}=  Update Account contact information   ${PUSERNAME0}   ${email}  ${secondary-phone}   ${whatsapp1}  ${EMPTY}  ${salutation}  ${firstname1}  ${lastname1}   
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Get Account contact information
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['account']}      ${pid}
    Should Be Equal As Strings  ${resp.json()['primaryPhoneNumber']}  ${PUSERNAME0}
    Should Be Equal As Strings  ${resp.json()['contactFirstName']}  ${firstname1}
    Should Be Equal As Strings  ${resp.json()['contactLastName']}  ${lastname1}
    Should Be Equal As Strings  ${resp.json()['salutation']}   ${salutation}
    Should Be Equal As Strings  ${resp.json()['primaryEmail']}  ${email}
    Should Be Equal As Strings  ${resp.json()['whatsappPhoneNumber']}   ${whatsapp1}
    Should Be Equal As Strings  ${resp.json()['emailVerified']}  ${bool[0]} 
    Should Be Equal As Strings  ${resp.json()['phoneVerified']}  ${bool[1]} 
    
    ${resp}=   Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    comment   LICENSE
    Should Be Equal As Strings  ${resp.json()[4]['resourceType']}  ${NotificationResourceType[2]}
    Should Be Equal As Strings  ${resp.json()[4]['eventType']}  ${EventType[9]}
    Should Be Equal As Strings  ${resp.json()[4]['email'][0]}   ${email} 
    Should Be Equal As Strings  ${resp.json()[4]['sms'][0]}  ${PUSERNAME0}
    Should Be Equal As Strings  ${resp.json()[4]['pushMsg'][0]}  ${PUSERNAME0}

    ${firstname2}=  FakerLibrary.first_name
    ${lastname2}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}=  Random Element    ${Genderlist}
    Set Test Variable  ${email}  ${firstname2}${PUSERNAME0}${C_Email}.${test_mail}
    ${resp}=   Update Service Provider With Emailid    ${pro_id0}  ${firstName2}  ${lastName2}  ${gender}  ${dob}  ${None}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Provider Details    ${pro_id0} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Account contact information
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['account']}      ${pid}
    Should Be Equal As Strings  ${resp.json()['primaryPhoneNumber']}  ${PUSERNAME0}
    Should Be Equal As Strings  ${resp.json()['contactFirstName']}  ${firstname2}
    Should Be Equal As Strings  ${resp.json()['contactLastName']}  ${lastname2}
    Should Be Equal As Strings  ${resp.json()['salutation']}   ${salutation}
    Should Be Equal As Strings  ${resp.json()['emailVerified']}  ${bool[0]} 
    Should Be Equal As Strings  ${resp.json()['phoneVerified']}  ${bool[1]} 

    ${resp}=   Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    comment   LICENSE
    Should Be Equal As Strings  ${resp.json()[4]['resourceType']}  ${NotificationResourceType[2]}
    Should Be Equal As Strings  ${resp.json()[4]['eventType']}  ${EventType[9]}
    Should Be Equal As Strings  ${resp.json()[4]['email'][0]}  ${None}
    Should Be Equal As Strings  ${resp.json()[4]['sms'][0]}  ${PUSERNAME0}
    Should Be Equal As Strings  ${resp.json()[4]['pushMsg'][0]}  ${PUSERNAME0}

JD-TC-Update Account Contact information-2
	[Documentation]  Update account contact information with  signup through primaryphonenumber(update basic information)then update provider details)
    ${domresp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${domresp.status_code}  200
    ${len}=  Get Length  ${domresp.json()}
    ${len}=  Evaluate  ${len}-1
    ${PUSERNAME0}=  Evaluate  ${PUSERNAME}+406011222
    Set Test Variable  ${d1}  ${domresp.json()[${len}]['domain']}    
    Set Test Variable  ${sd}  ${domresp.json()[${len}]['subDomains'][0]['subDomain']} 
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${d1}  ${sd}  ${PUSERNAME0}   ${highest_package[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAME0}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAME0}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Encrypted Provider Login  ${PUSERNAME0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${pro_id0}  ${decrypted_data['id']}
    # Set Test Variable  ${pro_id0}  ${resp.json()['id']}
    Set Suite Variable  ${PUSERNAME0}
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERNAME0}${\n}  
    ${pid}=  get_acc_id  ${PUSERNAME0}
    ${resp}=  Get Provider Details    ${pro_id0} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['basicInfo']['id']}          ${pro_id0}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['firstName']}   ${firstname}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['lastName']}    ${lastname}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['mobile']}       ${PUSERNAME0}
    # Should Be Equal As Strings  ${resp.json()['basicInfo']['emailVerified']}   ${bool[0]} 
    # Should Be Equal As Strings  ${resp.json()['basicInfo']['phoneVerified']}   ${bool[1]} 

    ${resp}=   Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    comment   WAITLISTADD
    Should Be Equal As Strings  ${resp.json()[0]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['eventType']}     ${EventType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['email']}         []
    Should Be Equal As Strings  ${resp.json()[0]['sms'][0]}        ${PUSERNAME0}
    Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]}    ${PUSERNAME0}
    comment   WAITLIST-CANCEL
    Should Be Equal As Strings  ${resp.json()[1]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[1]['eventType']}     ${EventType[1]}
    Should Be Equal As Strings  ${resp.json()[1]['email']}         []
    Should Be Equal As Strings  ${resp.json()[1]['sms'][0]}        ${PUSERNAME0}
    Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]}    ${PUSERNAME0}
    comment   APPOINTMENTADD
    Should Be Equal As Strings  ${resp.json()[2]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[2]['eventType']}     ${EventType[7]}
    Should Be Equal As Strings  ${resp.json()[2]['email']}         []
    Should Be Equal As Strings  ${resp.json()[2]['sms'][0]}        ${PUSERNAME0}
    Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]}     ${PUSERNAME0}
    comment   APPOINTMENT-CANCEL
    Should Be Equal As Strings  ${resp.json()[3]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[3]['eventType']}     ${EventType[8]}
    Should Be Equal As Strings  ${resp.json()[3]['email']}         []
    Should Be Equal As Strings  ${resp.json()[3]['sms'][0]}         ${PUSERNAME0}
    Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]}    ${PUSERNAME0}
    comment   LICENSE
    Should Be Equal As Strings  ${resp.json()[4]['resourceType']}  ${NotificationResourceType[2]}
    Should Be Equal As Strings  ${resp.json()[4]['eventType']}  ${EventType[9]}
    Should Be Equal As Strings  ${resp.json()[4]['email']}  []
    Should Be Equal As Strings  ${resp.json()[4]['sms'][0]}  ${PUSERNAME0}
    Should Be Equal As Strings  ${resp.json()[4]['pushMsg'][0]}  ${PUSERNAME0}

    ${resp}=  Get Account contact information
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['account']}      ${pid}
    Should Be Equal As Strings  ${resp.json()['primaryPhoneNumber']}  ${PUSERNAME0}
    Should Be Equal As Strings  ${resp.json()['contactFirstName']}  ${firstname}
    Should Be Equal As Strings  ${resp.json()['contactLastName']}  ${lastname}
    Should Be Equal As Strings  ${resp.json()['emailVerified']}  ${bool[0]} 
    Should Be Equal As Strings  ${resp.json()['phoneVerified']}  ${bool[1]} 

    ${firstname1}=  FakerLibrary.first_name
    ${lastname1}=  FakerLibrary.last_name
    ${whatsapp1}=   Evaluate  ${PUSERNAME}+406100222
    ${secondary-phone}=  Evaluate  ${PUSERNAME}+406000223
    Set Test Variable  ${email}  ${firstname}${PUSERNAME0}${C_Email}.${test_mail}
    Set Suite Variable  ${email0}  ${firstname1}${PUSERNAME0}${C_Email}.${test_mail}
    ${resp}=  Update Account contact information   ${PUSERNAME0}   ${email}  ${secondary-phone}   ${whatsapp1}  ${email0}  ${salutation}  ${firstname1}  ${lastname1}   
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Get Account contact information
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['account']}      ${pid}
    Should Be Equal As Strings  ${resp.json()['primaryPhoneNumber']}  ${PUSERNAME0}
    Should Be Equal As Strings  ${resp.json()['contactFirstName']}  ${firstname1}
    Should Be Equal As Strings  ${resp.json()['contactLastName']}  ${lastname1}
    Should Be Equal As Strings  ${resp.json()['salutation']}   ${salutation}
    Should Be Equal As Strings  ${resp.json()['primaryEmail']}  ${email}
    Should Be Equal As Strings  ${resp.json()['secondaryPhoneNumber']}  ${secondary-phone}
    Should Be Equal As Strings  ${resp.json()['whatsappPhoneNumber']}   ${whatsapp1}
    Should Be Equal As Strings  ${resp.json()['emailVerified']}  ${bool[0]} 
    Should Be Equal As Strings  ${resp.json()['phoneVerified']}  ${bool[1]} 
    
    ${resp}=   Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    comment   LICENSE
    Should Be Equal As Strings  ${resp.json()[4]['resourceType']}  ${NotificationResourceType[2]}
    Should Be Equal As Strings  ${resp.json()[4]['eventType']}  ${EventType[9]}
    Should Be Equal As Strings  ${resp.json()[4]['email'][0]}   ${email} 
    Should Be Equal As Strings  ${resp.json()[4]['sms'][0]}  ${PUSERNAME0}
    Should Be Equal As Strings  ${resp.json()[4]['pushMsg'][0]}  ${PUSERNAME0}

    ${firstname2}=  FakerLibrary.first_name
    ${lastname2}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}=  Random Element    ${Genderlist}
    Set Test Variable  ${email_1}  ${firstname2}${PUSERNAME0}${C_Email}.${test_mail}
    ${resp}=   Update Service Provider With Emailid    ${pro_id0}  ${firstName2}  ${lastName2}  ${gender}  ${dob}  ${email_1}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Account contact information
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['account']}      ${pid}
    Should Be Equal As Strings  ${resp.json()['primaryPhoneNumber']}  ${PUSERNAME0}
    Should Be Equal As Strings  ${resp.json()['contactFirstName']}  ${firstname2}
    Should Be Equal As Strings  ${resp.json()['contactLastName']}  ${lastname2}
    Should Be Equal As Strings  ${resp.json()['salutation']}   ${salutation}
    Should Be Equal As Strings  ${resp.json()['primaryEmail']}  ${email_1}
    Should Be Equal As Strings  ${resp.json()['emailVerified']}  ${bool[0]} 
    Should Be Equal As Strings  ${resp.json()['phoneVerified']}  ${bool[1]} 

    ${resp}=   Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    comment   LICENSE
    Should Be Equal As Strings  ${resp.json()[4]['resourceType']}  ${NotificationResourceType[2]}
    Should Be Equal As Strings  ${resp.json()[4]['eventType']}  ${EventType[9]}
    Should Be Equal As Strings  ${resp.json()[4]['email'][0]}   ${email_1} 
    Should Be Equal As Strings  ${resp.json()[4]['sms'][0]}  ${PUSERNAME0}
    Should Be Equal As Strings  ${resp.json()[4]['pushMsg'][0]}  ${PUSERNAME0}
  