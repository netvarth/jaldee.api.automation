
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


*** Test Cases ***
JD-TC-Get Account Contact information-1
	[Documentation]  Get account contact information with  signup through primaryphonenumber and provider update basic details (firstname and lastname)
    ${domresp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${domresp.status_code}  200
    ${len}=  Get Length  ${domresp.json()}
    ${len}=  Evaluate  ${len}-1
    ${PUSERNAME}=  Evaluate  ${PUSERNAME}+405000222
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
    
# *** Comments ***
    ${resp}=  Account Set Credential  ${PUSERNAME}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Encrypted Provider Login  ${PUSERNAME}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${PUSERNAME}
    Set Test Variable  ${pro_id}  ${resp.json()['id']}
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME}${\n} 

    ${pid}=  get_acc_id  ${PUSERNAME}
    ${resp}=  Get Provider Details    ${pro_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['basicInfo']['id']}          ${pro_id}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['firstName']}   ${firstname}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['lastName']}    ${lastname}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['mobile']}       ${PUSERNAME}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['emailVerified']}   ${bool[0]} 
    Should Be Equal As Strings  ${resp.json()['basicInfo']['phoneVerified']}   ${bool[1]} 

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
    Should Be Equal As Strings  ${resp.json()[1]['email']}          []
    Should Be Equal As Strings  ${resp.json()[1]['sms'][0]['number']}           ${PUSERNAME} 
    Should Be Equal As Strings  ${resp.json()[1]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]['number']}       ${PUSERNAME} 
    Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[1]['sms'][0]}        ${PUSERNAME}
    # Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]}    ${PUSERNAME}
    comment   APPOINTMENTADD
    Should Be Equal As Strings  ${resp.json()[2]['resourceType']}   ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[2]['eventType']}       ${EventType[7]}
    Should Be Equal As Strings  ${resp.json()[2]['email']}           []
    Should Be Equal As Strings  ${resp.json()[2]['sms'][0]['number']}           ${PUSERNAME} 
    Should Be Equal As Strings  ${resp.json()[2]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]['number']}       ${PUSERNAME} 
    Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[2]['sms'][0]}          ${PUSERNAME}
    # Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]}      ${PUSERNAME}
    comment   APPOINTMENT-CANCEL
    Should Be Equal As Strings  ${resp.json()[3]['resourceType']}   ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[3]['eventType']}      ${EventType[8]}
    Should Be Equal As Strings  ${resp.json()[3]['email']}          []
    Should Be Equal As Strings  ${resp.json()[3]['sms'][0]['number']}           ${PUSERNAME} 
    Should Be Equal As Strings  ${resp.json()[3]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]['number']}       ${PUSERNAME} 
    Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[3]['sms'][0]}         ${PUSERNAME}
    # Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]}     ${PUSERNAME}
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
    Should Be Equal As Strings  ${resp.json()[5]['email']}         []
    Should Be Equal As Strings  ${resp.json()[5]['sms'][0]['number']}           ${PUSERNAME} 
    Should Be Equal As Strings  ${resp.json()[5]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[5]['pushMsg'][0]['number']}       ${PUSERNAME} 
    Should Be Equal As Strings  ${resp.json()[5]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[5]['sms'][0]}        ${PUSERNAME}
    # Should Be Equal As Strings  ${resp.json()[5]['pushMsg'][0]}    ${PUSERNAME}

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
    ${dob}=  FakerLibrary.Date
    ${gender}=  Random Element    ${Genderlist}
    Set Test Variable  ${email}  ${firstname1}${PUSERNAME0}${C_Email}.${test_mail}
    ${resp}=   Update Service Provider With Emailid    ${pro_id}  ${firstName1}  ${lastName1}  ${gender}  ${dob}  ${email}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Provider Details    ${pro_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['basicInfo']['id']}          ${pro_id}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['firstName']}   ${firstname1}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['lastName']}    ${lastname1}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['mobile']}      ${PUSERNAME}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['email']}        ${email}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['emailVerified']}   ${bool[1]} 
    Should Be Equal As Strings  ${resp.json()['basicInfo']['phoneVerified']}   ${bool[1]} 

    ${resp}=   Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    # comment   LICENSE
    # Should Be Equal As Strings  ${resp.json()[4]['resourceType']}  ${NotificationResourceType[2]}
    # Should Be Equal As Strings  ${resp.json()[4]['eventType']}  ${EventType[9]}
    # Should Be Equal As Strings  ${resp.json()[4]['email'][0]}  ${email}
    # Should Be Equal As Strings  ${resp.json()[4]['sms'][0]}  ${PUSERNAME}
    # Should Be Equal As Strings  ${resp.json()[4]['pushMsg'][0]}  ${PUSERNAME}
    comment   WAITLISTADD
    Should Be Equal As Strings  ${resp.json()[0]['resourceType']}    ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['eventType']}       ${EventType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['email']}           []
    Should Be Equal As Strings  ${resp.json()[0]['sms'][0]['number']}           ${PUSERNAME} 
    Should Be Equal As Strings  ${resp.json()[0]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]['number']}       ${PUSERNAME} 
    Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[0]['sms'][0]}           ${PUSERNAME}
    # Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]}       ${PUSERNAME}
    comment   WAITLIST-CANCEL
    Should Be Equal As Strings  ${resp.json()[1]['resourceType']}   ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[1]['eventType']}       ${EventType[1]}
    Should Be Equal As Strings  ${resp.json()[1]['email']}           []
    Should Be Equal As Strings  ${resp.json()[1]['sms'][0]['number']}           ${PUSERNAME} 
    Should Be Equal As Strings  ${resp.json()[1]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]['number']}       ${PUSERNAME} 
    Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[1]['sms'][0]}           ${PUSERNAME}
    # Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]}       ${PUSERNAME}
    comment   APPOINTMENTADD
    Should Be Equal As Strings  ${resp.json()[2]['resourceType']}   ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[2]['eventType']}      ${EventType[7]}
    Should Be Equal As Strings  ${resp.json()[2]['email']}           []
    Should Be Equal As Strings  ${resp.json()[2]['sms'][0]['number']}           ${PUSERNAME} 
    Should Be Equal As Strings  ${resp.json()[2]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]['number']}       ${PUSERNAME} 
    Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[2]['sms'][0]}          ${PUSERNAME}
    # Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]}      ${PUSERNAME}
    comment   APPOINTMENT-CANCEL
    Should Be Equal As Strings  ${resp.json()[3]['resourceType']}    ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[3]['eventType']}       ${EventType[8]}
    Should Be Equal As Strings  ${resp.json()[3]['email']}           []
    Should Be Equal As Strings  ${resp.json()[3]['sms'][0]['number']}           ${PUSERNAME} 
    Should Be Equal As Strings  ${resp.json()[3]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]['number']}       ${PUSERNAME} 
    Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[3]['sms'][0]}           ${PUSERNAME}
    # Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]}       ${PUSERNAME}
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
    Should Be Equal As Strings  ${resp.json()[5]['resourceType']}     ${NotificationResourceType[2]}
    Should Be Equal As Strings  ${resp.json()[5]['eventType']}        ${EventType[9]}
    Should Be Equal As Strings  ${resp.json()[5]['email']}             []
    Should Be Equal As Strings  ${resp.json()[5]['sms'][0]['number']}           ${PUSERNAME} 
    Should Be Equal As Strings  ${resp.json()[5]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[5]['pushMsg'][0]['number']}       ${PUSERNAME} 
    Should Be Equal As Strings  ${resp.json()[5]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[5]['sms'][0]}            ${PUSERNAME}
    # Should Be Equal As Strings  ${resp.json()[5]['pushMsg'][0]}        ${PUSERNAME}

    ${resp}=  Get Account contact information
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['account']}                ${pid}
    Should Be Equal As Strings  ${resp.json()['primaryPhoneNumber']}     ${PUSERNAME}
    Should Be Equal As Strings  ${resp.json()['contactFirstName']}       ${firstname1}
    Should Be Equal As Strings  ${resp.json()['contactLastName']}        ${lastname1}
    Should Be Equal As Strings  ${resp.json()['primaryEmail']}           ${email}
    Should Be Equal As Strings  ${resp.json()['emailVerified']}          ${bool[0]} 
    Should Be Equal As Strings  ${resp.json()['phoneVerified']}          ${bool[1]} 

JD-TC-Get Account Contact information-2
	[Documentation]  Get account contact information with  signup through primaryphonenumber and update provider number and other details
    ${domresp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${domresp.status_code}  200
    ${len}=  Get Length  ${domresp.json()}
    ${len}=  Evaluate  ${len}-1
    ${PUSERNAME1}=  Evaluate  ${PUSERNAME}+405059222
    Set Test Variable  ${d1}  ${domresp.json()[${len}]['domain']}    
    Set Test Variable  ${sd}  ${domresp.json()[${len}]['subDomains'][0]['subDomain']} 
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${d1}  ${sd}  ${PUSERNAME1}   ${highest_package[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAME1}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAME1}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Encrypted Provider Login  ${PUSERNAME1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${PUSERNAME1}
    Set Test Variable  ${pro_id1}  ${resp.json()['id']}
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME1}${\n} 

    ${pid}=  get_acc_id  ${PUSERNAME1}
    ${resp}=  Get Provider Details    ${pro_id1} 
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['basicInfo']['id']}             ${pro_id1}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['firstName']}      ${firstname}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['lastName']}        ${lastname}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['mobile']}          ${PUSERNAME1}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['emailVerified']}   ${bool[0]} 
    Should Be Equal As Strings  ${resp.json()['basicInfo']['phoneVerified']}   ${bool[1]} 

    ${resp}=   Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    comment   WAITLISTADD
    Should Be Equal As Strings  ${resp.json()[0]['resourceType']}    ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['eventType']}       ${EventType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['email']}           []
    Should Be Equal As Strings  ${resp.json()[0]['sms'][0]['number']}           ${PUSERNAME1} 
    Should Be Equal As Strings  ${resp.json()[0]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]['number']}       ${PUSERNAME1} 
    Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[0]['sms'][0]}          ${PUSERNAME1}
    # Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]}      ${PUSERNAME1}
    comment   WAITLIST-CANCEL
    Should Be Equal As Strings  ${resp.json()[1]['resourceType']}    ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[1]['eventType']}       ${EventType[1]}
    Should Be Equal As Strings  ${resp.json()[1]['email']}            []
    Should Be Equal As Strings  ${resp.json()[1]['sms'][0]['number']}           ${PUSERNAME1} 
    Should Be Equal As Strings  ${resp.json()[1]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]['number']}       ${PUSERNAME1} 
    Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[1]['sms'][0]}           ${PUSERNAME1}
    # Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]}       ${PUSERNAME1}
    comment   APPOINTMENTADD
    Should Be Equal As Strings  ${resp.json()[2]['resourceType']}      ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[2]['eventType']}         ${EventType[7]}
    Should Be Equal As Strings  ${resp.json()[2]['email']}             []
    Should Be Equal As Strings  ${resp.json()[2]['sms'][0]['number']}           ${PUSERNAME1} 
    Should Be Equal As Strings  ${resp.json()[2]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]['number']}       ${PUSERNAME1} 
    Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[2]['sms'][0]}            ${PUSERNAME1}
    # Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]}        ${PUSERNAME1}
    comment   APPOINTMENT-CANCEL
    Should Be Equal As Strings  ${resp.json()[3]['resourceType']}   ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[3]['eventType']}      ${EventType[8]}
    Should Be Equal As Strings  ${resp.json()[3]['email']}          []
    Should Be Equal As Strings  ${resp.json()[3]['sms'][0]['number']}           ${PUSERNAME1} 
    Should Be Equal As Strings  ${resp.json()[3]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]['number']}       ${PUSERNAME1} 
    Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[3]['sms'][0]}         ${PUSERNAME1}
    # Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]}     ${PUSERNAME1}
    comment   DONATION
    Should Be Equal As Strings  ${resp.json()[4]['resourceType']}  ${NotificationResourceType[3]}
    Should Be Equal As Strings  ${resp.json()[4]['eventType']}     ${EventType[10]}
    Should Be Equal As Strings  ${resp.json()[4]['email']}         []
    Should Be Equal As Strings  ${resp.json()[4]['sms'][0]['number']}           ${PUSERNAME1} 
    Should Be Equal As Strings  ${resp.json()[4]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[4]['pushMsg'][0]['number']}       ${PUSERNAME1} 
    Should Be Equal As Strings  ${resp.json()[4]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[4]['sms'][0]}        ${PUSERNAME1}
    # Should Be Equal As Strings  ${resp.json()[4]['pushMsg'][0]}    ${PUSERNAME1}
    comment   LICENSE
    Should Be Equal As Strings  ${resp.json()[5]['resourceType']}  ${NotificationResourceType[2]}
    Should Be Equal As Strings  ${resp.json()[5]['eventType']}      ${EventType[9]}
    Should Be Equal As Strings  ${resp.json()[5]['email']}          []
    Should Be Equal As Strings  ${resp.json()[5]['sms'][0]['number']}           ${PUSERNAME1} 
    Should Be Equal As Strings  ${resp.json()[5]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[5]['pushMsg'][0]['number']}       ${PUSERNAME1} 
    Should Be Equal As Strings  ${resp.json()[5]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[5]['sms'][0]}          ${PUSERNAME1}
    # Should Be Equal As Strings  ${resp.json()[5]['pushMsg'][0]}       ${PUSERNAME1}

    ${resp}=  Get Account contact information
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['account']}              ${pid}
    Should Be Equal As Strings  ${resp.json()['primaryPhoneNumber']}   ${PUSERNAME1}
    Should Be Equal As Strings  ${resp.json()['contactFirstName']}     ${firstname}
    Should Be Equal As Strings  ${resp.json()['contactLastName']}      ${lastname}
    Should Be Equal As Strings  ${resp.json()['emailVerified']}        ${bool[0]} 
    Should Be Equal As Strings  ${resp.json()['phoneVerified']}        ${bool[1]} 

    ${firstname1}=  FakerLibrary.first_name
    ${lastname1}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}=  Random Element    ${Genderlist}
    Set Test Variable  ${email}  ${firstname1}${PUSERNAME0}${C_Email}.${test_mail}
    ${resp}=   Update Service Provider With Emailid    ${pro_id1}  ${firstName1}  ${lastName1}  ${gender}  ${dob}  ${email}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${PUSERNAME_1}=  Evaluate  ${PUSERNAME}+405058122
    ${resp}=  Send Verify Login   ${PUSERNAME_1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Verify Login   ${PUSERNAME_1}  4
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Provider Details    ${pro_id1} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['basicInfo']['id']}          ${pro_id1}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['firstName']}   ${firstname1}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['lastName']}    ${lastname1}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['mobile']}      ${PUSERNAME_1}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['email']}        ${email}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['emailVerified']}   ${bool[1]} 
    Should Be Equal As Strings  ${resp.json()['basicInfo']['phoneVerified']}   ${bool[1]} 

    ${resp}=   Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    comment   WAITLISTADD
    Should Be Equal As Strings  ${resp.json()[0]['resourceType']}   ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['eventType']}      ${EventType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['email']}          []
    Should Be Equal As Strings  ${resp.json()[0]['sms'][0]['number']}           ${PUSERNAME_1} 
    Should Be Equal As Strings  ${resp.json()[0]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]['number']}       ${PUSERNAME_1} 
    Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[0]['sms'][0]}          ${PUSERNAME_1}
    # Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]}      ${PUSERNAME_1}
    comment   WAITLIST-CANCEL
    Should Be Equal As Strings  ${resp.json()[1]['resourceType']}   ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[1]['eventType']}      ${EventType[1]}
    Should Be Equal As Strings  ${resp.json()[1]['email']}          []
    Should Be Equal As Strings  ${resp.json()[1]['sms'][0]['number']}           ${PUSERNAME_1} 
    Should Be Equal As Strings  ${resp.json()[1]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]['number']}       ${PUSERNAME_1} 
    Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[1]['sms'][0]}         ${PUSERNAME_1}
    # Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]}     ${PUSERNAME_1}
    comment   APPOINTMENTADD
    Should Be Equal As Strings  ${resp.json()[2]['resourceType']}    ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[2]['eventType']}       ${EventType[7]}
    Should Be Equal As Strings  ${resp.json()[2]['email']}           []
    Should Be Equal As Strings  ${resp.json()[2]['sms'][0]['number']}           ${PUSERNAME_1} 
    Should Be Equal As Strings  ${resp.json()[2]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]['number']}       ${PUSERNAME_1} 
    Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[2]['sms'][0]}          ${PUSERNAME_1}
    # Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]}      ${PUSERNAME_1}
    comment   APPOINTMENT-CANCEL
    Should Be Equal As Strings  ${resp.json()[3]['resourceType']}   ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[3]['eventType']}      ${EventType[8]}
    Should Be Equal As Strings  ${resp.json()[3]['email']}          []
    Should Be Equal As Strings  ${resp.json()[3]['sms'][0]['number']}           ${PUSERNAME_1} 
    Should Be Equal As Strings  ${resp.json()[3]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]['number']}       ${PUSERNAME_1} 
    Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[3]['sms'][0]}         ${PUSERNAME_1}
    # Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]}     ${PUSERNAME_1}
    comment   DONATION
    Should Be Equal As Strings  ${resp.json()[4]['resourceType']}  ${NotificationResourceType[3]}
    Should Be Equal As Strings  ${resp.json()[4]['eventType']}     ${EventType[10]}
    Should Be Equal As Strings  ${resp.json()[4]['email']}         []
    Should Be Equal As Strings  ${resp.json()[4]['sms'][0]['number']}           ${PUSERNAME_1} 
    Should Be Equal As Strings  ${resp.json()[4]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[4]['pushMsg'][0]['number']}       ${PUSERNAME_1} 
    Should Be Equal As Strings  ${resp.json()[4]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[4]['sms'][0]}        ${PUSERNAME_1}
    # Should Be Equal As Strings  ${resp.json()[4]['pushMsg'][0]}    ${PUSERNAME_1}
    comment   LICENSE
    Should Be Equal As Strings  ${resp.json()[5]['resourceType']}  ${NotificationResourceType[2]}
    Should Be Equal As Strings  ${resp.json()[5]['eventType']}     ${EventType[9]}
    Should Be Equal As Strings  ${resp.json()[5]['email']}         []
    Should Be Equal As Strings  ${resp.json()[5]['sms'][0]['number']}           ${PUSERNAME_1} 
    Should Be Equal As Strings  ${resp.json()[5]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[5]['pushMsg'][0]['number']}       ${PUSERNAME_1} 
    Should Be Equal As Strings  ${resp.json()[5]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[5]['sms'][0]}        ${PUSERNAME_1}
    # Should Be Equal As Strings  ${resp.json()[5]['pushMsg'][0]}     ${PUSERNAME_1}

    ${resp}=  Get Account contact information
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['account']}             ${pid}
    Should Be Equal As Strings  ${resp.json()['primaryPhoneNumber']}  ${PUSERNAME_1}
    Should Be Equal As Strings  ${resp.json()['contactFirstName']}    ${firstname1}
    Should Be Equal As Strings  ${resp.json()['contactLastName']}     ${lastname1}
    Should Be Equal As Strings  ${resp.json()['primaryEmail']}        ${email}
    Should Be Equal As Strings  ${resp.json()['emailVerified']}       ${bool[0]} 
    Should Be Equal As Strings  ${resp.json()['phoneVerified']}       ${bool[1]} 

JD-TC-Get Account Contact information-3
	[Documentation]  Get account contact information with  signup through email 
    ${domresp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${domresp.status_code}  200
    ${len}=  Get Length  ${domresp.json()}
    ${len}=  Evaluate  ${len}-1
    ${PUSERNAME0}=  Evaluate  ${PUSERNAME0}+405011222
    Set Test Variable  ${d1}  ${domresp.json()[${len}]['domain']}    
    Set Test Variable  ${sd}  ${domresp.json()[${len}]['subDomains'][0]['subDomain']} 
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    # ${highest_package}=  get_highest_license_pkg
    ${lowest_package}=   get_lowest_license_pkg
    Set Test Variable  ${email}  ${firstname}${PUSERNAME0}${C_Email}.${test_mail}
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${email}  ${d1}  ${sd}  ${PUSERNAME0}   ${lowest_package[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${email}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${email}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Encrypted Provider Login  ${PUSERNAME0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${pro_id2}  ${resp.json()['id']}
    Set Suite Variable  ${PUSERNAME0}
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME0}${\n}
    ${pid0}=  get_acc_id  ${PUSERNAME0}  
    ${resp}=  Get Account contact information
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['account']}            ${pid0}
    Should Be Equal As Strings  ${resp.json()['primaryPhoneNumber']}  ${PUSERNAME0}
    Should Be Equal As Strings  ${resp.json()['contactFirstName']}    ${firstname}
    Should Be Equal As Strings  ${resp.json()['contactLastName']}     ${lastname}
    Should Be Equal As Strings  ${resp.json()['primaryEmail']}        ${email}
    Should Be Equal As Strings  ${resp.json()['emailVerified']}       ${bool[1]} 
    Should Be Equal As Strings  ${resp.json()['phoneVerified']}       ${bool[0]} 

    ${resp}=   Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    comment   WAITLISTADD
    Should Be Equal As Strings  ${resp.json()[0]['resourceType']}    ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['eventType']}       ${EventType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['email'][0]}        ${email}
    Should Be Equal As Strings  ${resp.json()[0]['sms'][0]['number']}           ${PUSERNAME0} 
    Should Be Equal As Strings  ${resp.json()[0]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]['number']}       ${PUSERNAME0} 
    Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[0]['sms'][0]}          ${PUSERNAME0}
    # Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]}      ${PUSERNAME0}
    comment   WAITLIST-CANCEL
    Should Be Equal As Strings  ${resp.json()[1]['resourceType']}   ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[1]['eventType']}      ${EventType[1]}
    Should Be Equal As Strings  ${resp.json()[1]['email'][0]}       ${email}
    Should Be Equal As Strings  ${resp.json()[1]['sms'][0]['number']}           ${PUSERNAME0} 
    Should Be Equal As Strings  ${resp.json()[1]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]['number']}       ${PUSERNAME0} 
    Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[1]['sms'][0]}         ${PUSERNAME0}
    # Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]}     ${PUSERNAME0}
    comment   APPOINTMENTADD
    Should Be Equal As Strings  ${resp.json()[2]['resourceType']}   ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[2]['eventType']}      ${EventType[7]}
    Should Be Equal As Strings  ${resp.json()[2]['email'][0]}       ${email}
    Should Be Equal As Strings  ${resp.json()[2]['sms'][0]['number']}           ${PUSERNAME0} 
    Should Be Equal As Strings  ${resp.json()[2]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]['number']}       ${PUSERNAME0} 
    Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[2]['sms'][0]}         ${PUSERNAME0}
    # Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]}     ${PUSERNAME0}
    comment   APPOINTMENT-CANCEL
    Should Be Equal As Strings  ${resp.json()[3]['resourceType']}   ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[3]['eventType']}      ${EventType[8]}
    Should Be Equal As Strings  ${resp.json()[3]['email'][0]}       ${email}
    Should Be Equal As Strings  ${resp.json()[3]['sms'][0]['number']}           ${PUSERNAME0} 
    Should Be Equal As Strings  ${resp.json()[3]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]['number']}       ${PUSERNAME0} 
    Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[3]['sms'][0]}         ${PUSERNAME0}
    # Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]}     ${PUSERNAME0}
    comment   DONATION
    Should Be Equal As Strings  ${resp.json()[4]['resourceType']}  ${NotificationResourceType[3]}
    Should Be Equal As Strings  ${resp.json()[4]['eventType']}     ${EventType[10]}
    Should Be Equal As Strings  ${resp.json()[4]['email'][0]}      ${email}
    Should Be Equal As Strings  ${resp.json()[4]['sms'][0]['number']}           ${PUSERNAME0} 
    Should Be Equal As Strings  ${resp.json()[4]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[4]['pushMsg'][0]['number']}       ${PUSERNAME0} 
    Should Be Equal As Strings  ${resp.json()[4]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[4]['sms'][0]}        ${PUSERNAME0}
    # Should Be Equal As Strings  ${resp.json()[4]['pushMsg'][0]}    ${PUSERNAME0}
    comment   LICENSE
    Should Be Equal As Strings  ${resp.json()[5]['resourceType']}   ${NotificationResourceType[2]}
    Should Be Equal As Strings  ${resp.json()[5]['eventType']}      ${EventType[9]}
    Should Be Equal As Strings  ${resp.json()[5]['email'][0]}       ${email}
    Should Be Equal As Strings  ${resp.json()[5]['sms'][0]['number']}           ${PUSERNAME0} 
    Should Be Equal As Strings  ${resp.json()[5]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[5]['pushMsg'][0]['number']}       ${PUSERNAME0} 
    Should Be Equal As Strings  ${resp.json()[5]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[5]['sms'][0]}         ${PUSERNAME0}
    # Should Be Equal As Strings  ${resp.json()[5]['pushMsg'][0]}     ${PUSERNAME0}

    ${firstname1}=  FakerLibrary.first_name
    ${lastname1}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}=  Random Element    ${Genderlist}
    # Set Test Variable  ${email1}  ${firstname1}${PUSERNAME0}${C_Email}.${test_mail}
    ${resp}=   Update Service Provider With Emailid    ${pro_id2}  ${firstName1}  ${lastName1}  ${gender}  ${dob}  ${email}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Provider Details    ${pro_id2} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['basicInfo']['id']}          ${pro_id2}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['firstName']}   ${firstname1}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['lastName']}    ${lastname1}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['mobile']}      ${PUSERNAME0}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['email']}        ${email}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['emailVerified']}   ${bool[1]} 
    Should Be Equal As Strings  ${resp.json()['basicInfo']['phoneVerified']}   ${bool[0]} 

    ${resp}=   Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Account contact information
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['account']}             ${pid0}
    Should Be Equal As Strings  ${resp.json()['primaryPhoneNumber']}  ${PUSERNAME0}
    Should Be Equal As Strings  ${resp.json()['contactFirstName']}    ${firstname1}
    Should Be Equal As Strings  ${resp.json()['contactLastName']}     ${lastname1}
    Should Be Equal As Strings  ${resp.json()['primaryEmail']}        ${email}
    Should Be Equal As Strings  ${resp.json()['emailVerified']}      ${bool[1]} 
    Should Be Equal As Strings  ${resp.json()['phoneVerified']}      ${bool[0]} 

JD-TC-Get Account Contact information-4
	[Documentation]  Get account contact information with  signup through email and update provider email with empty
    ${domresp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${domresp.status_code}  200
    ${len}=  Get Length  ${domresp.json()}
    ${len}=  Evaluate  ${len}-1
    ${PUSERNAME2}=  Evaluate  ${PUSERNAME0}+405317222
    Set Test Variable  ${d1}  ${domresp.json()[${len}]['domain']}    
    Set Test Variable  ${sd}  ${domresp.json()[${len}]['subDomains'][0]['subDomain']} 
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    # ${highest_package}=  get_highest_license_pkg
    ${lowest_package}=   get_lowest_license_pkg
    Set Test Variable  ${email}  ${firstname}${PUSERNAME2}${C_Email}.${test_mail}
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${email}  ${d1}  ${sd}  ${PUSERNAME2}   ${lowest_package[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${email}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${email}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Encrypted Provider Login  ${PUSERNAME2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${pro_id2}  ${resp.json()['id']}
    Set Suite Variable  ${PUSERNAME2}
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME2}${\n}
    ${pid0}=  get_acc_id  ${PUSERNAME2}  
    ${resp}=  Get Account contact information
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['account']}             ${pid0}
    Should Be Equal As Strings  ${resp.json()['primaryPhoneNumber']}  ${PUSERNAME2}
    Should Be Equal As Strings  ${resp.json()['contactFirstName']}    ${firstname}
    Should Be Equal As Strings  ${resp.json()['contactLastName']}     ${lastname}
    Should Be Equal As Strings  ${resp.json()['primaryEmail']}        ${email}
    Should Be Equal As Strings  ${resp.json()['emailVerified']}       ${bool[1]} 
    Should Be Equal As Strings  ${resp.json()['phoneVerified']}       ${bool[0]} 

    ${resp}=   Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    comment   WAITLISTADD
    Should Be Equal As Strings  ${resp.json()[0]['resourceType']}    ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['eventType']}       ${EventType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['email'][0]}        ${email}
    Should Be Equal As Strings  ${resp.json()[0]['sms'][0]['number']}           ${PUSERNAME2} 
    Should Be Equal As Strings  ${resp.json()[0]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]['number']}       ${PUSERNAME2} 
    Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[0]['sms'][0]}           ${PUSERNAME2}
    # Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]}       ${PUSERNAME2}
    comment   WAITLIST-CANCEL
    Should Be Equal As Strings  ${resp.json()[1]['resourceType']}     ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[1]['eventType']}        ${EventType[1]}
    Should Be Equal As Strings  ${resp.json()[1]['email'][0]}         ${email}
    Should Be Equal As Strings  ${resp.json()[1]['sms'][0]['number']}           ${PUSERNAME2} 
    Should Be Equal As Strings  ${resp.json()[1]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]['number']}       ${PUSERNAME2} 
    Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[1]['sms'][0]}           ${PUSERNAME2}
    # Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]}       ${PUSERNAME2}
    comment   APPOINTMENTADD
    Should Be Equal As Strings  ${resp.json()[2]['resourceType']}    ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[2]['eventType']}       ${EventType[7]}
    Should Be Equal As Strings  ${resp.json()[2]['email'][0]}        ${email}
    Should Be Equal As Strings  ${resp.json()[2]['sms'][0]['number']}           ${PUSERNAME2} 
    Should Be Equal As Strings  ${resp.json()[2]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]['number']}       ${PUSERNAME2} 
    Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[2]['sms'][0]}          ${PUSERNAME2}
    # Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]}      ${PUSERNAME2}
    comment   APPOINTMENT-CANCEL
    Should Be Equal As Strings  ${resp.json()[3]['resourceType']}   ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[3]['eventType']}      ${EventType[8]}
    Should Be Equal As Strings  ${resp.json()[3]['email'][0]}       ${email}
    Should Be Equal As Strings  ${resp.json()[3]['sms'][0]['number']}           ${PUSERNAME2} 
    Should Be Equal As Strings  ${resp.json()[3]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]['number']}       ${PUSERNAME2} 
    Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[3]['sms'][0]}         ${PUSERNAME2}
    # Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]}     ${PUSERNAME2}
    comment   DONATION
    Should Be Equal As Strings  ${resp.json()[4]['resourceType']}  ${NotificationResourceType[3]}
    Should Be Equal As Strings  ${resp.json()[4]['eventType']}     ${EventType[10]}
    Should Be Equal As Strings  ${resp.json()[4]['email'][0]}      ${email}
    Should Be Equal As Strings  ${resp.json()[4]['sms'][0]['number']}           ${PUSERNAME2} 
    Should Be Equal As Strings  ${resp.json()[4]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[4]['pushMsg'][0]['number']}       ${PUSERNAME2} 
    Should Be Equal As Strings  ${resp.json()[4]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[4]['sms'][0]}        ${PUSERNAME2}
    # Should Be Equal As Strings  ${resp.json()[4]['pushMsg'][0]}    ${PUSERNAME2}
    comment   LICENSE
    Should Be Equal As Strings  ${resp.json()[5]['resourceType']}    ${NotificationResourceType[2]}
    Should Be Equal As Strings  ${resp.json()[5]['eventType']}       ${EventType[9]}
    Should Be Equal As Strings  ${resp.json()[5]['email'][0]}        ${email}
    Should Be Equal As Strings  ${resp.json()[5]['sms'][0]['number']}           ${PUSERNAME2} 
    Should Be Equal As Strings  ${resp.json()[5]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[5]['pushMsg'][0]['number']}       ${PUSERNAME2} 
    Should Be Equal As Strings  ${resp.json()[5]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[5]['sms'][0]}          ${PUSERNAME2}
    # Should Be Equal As Strings  ${resp.json()[5]['pushMsg'][0]}      ${PUSERNAME2}

    ${resp}=  Get Account contact information
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['account']}               ${pid0}
    Should Be Equal As Strings  ${resp.json()['primaryPhoneNumber']}    ${PUSERNAME2}
    Should Be Equal As Strings  ${resp.json()['contactFirstName']}      ${firstname}
    Should Be Equal As Strings  ${resp.json()['contactLastName']}       ${lastname}
    Should Be Equal As Strings  ${resp.json()['emailVerified']}         ${bool[1]} 
    Should Be Equal As Strings  ${resp.json()['phoneVerified']}         ${bool[0]} 

    ${firstname1}=  FakerLibrary.first_name
    ${lastname1}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}=  Random Element    ${Genderlist}
    # Set Test Variable  ${email1}  ${firstname1}${PUSERNAME0}${C_Email}.${test_mail}
    ${resp}=   Update Service Provider With Emailid    ${pro_id2}  ${firstName1}  ${lastName1}  ${gender}  ${dob}  ${EMPTY}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Provider Details    ${pro_id2} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['basicInfo']['id']}          ${pro_id2}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['firstName']}   ${firstname1}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['lastName']}    ${lastname1}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['mobile']}       ${PUSERNAME2}
    # Should Be Equal As Strings  ${resp.json()['basicInfo']['email']}   ${email}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['emailVerified']}   ${bool[0]} 
    Should Be Equal As Strings  ${resp.json()['basicInfo']['phoneVerified']}   ${bool[0]} 

    ${resp}=   Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Account contact information
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['account']}                ${pid0}
    Should Be Equal As Strings  ${resp.json()['primaryPhoneNumber']}     ${PUSERNAME2}
    Should Be Equal As Strings  ${resp.json()['contactFirstName']}       ${firstname1}
    Should Be Equal As Strings  ${resp.json()['contactLastName']}        ${lastname1}
    # Should Be Equal As Strings  ${resp.json()['primaryEmail']}  ${email}
    Should Be Equal As Strings  ${resp.json()['emailVerified']}         ${bool[0]} 
    Should Be Equal As Strings  ${resp.json()['phoneVerified']}         ${bool[0]} 

JD-TC-Get Account Contact information-5
	[Documentation]  Get account contact information with  signup through email and update provider's email 
    ${domresp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${domresp.status_code}  200
    ${len}=  Get Length  ${domresp.json()}
    ${len}=  Evaluate  ${len}-1
    ${PUSERNAME3}=  Evaluate  ${PUSERNAME0}+405618222
    Set Test Variable  ${d1}  ${domresp.json()[${len}]['domain']}    
    Set Test Variable  ${sd}  ${domresp.json()[${len}]['subDomains'][0]['subDomain']} 
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    # ${highest_package}=  get_highest_license_pkg
    ${lowest_package}=   get_lowest_license_pkg
    Set Test Variable  ${email}  ${firstname}${PUSERNAME2}${C_Email}.${test_mail}
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${email}  ${d1}  ${sd}  ${PUSERNAME3}   ${lowest_package[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${email}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${email}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Encrypted Provider Login  ${PUSERNAME3}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${pro_id2}  ${resp.json()['id']}
    Set Suite Variable  ${PUSERNAME3}
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME3}${\n}
    ${pid0}=  get_acc_id  ${PUSERNAME3}  
    ${resp}=  Get Account contact information
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['account']}              ${pid0}
    Should Be Equal As Strings  ${resp.json()['primaryPhoneNumber']}   ${PUSERNAME3}
    Should Be Equal As Strings  ${resp.json()['contactFirstName']}      ${firstname}
    Should Be Equal As Strings  ${resp.json()['contactLastName']}       ${lastname}
    Should Be Equal As Strings  ${resp.json()['primaryEmail']}          ${email}
    Should Be Equal As Strings  ${resp.json()['emailVerified']}         ${bool[1]} 
    Should Be Equal As Strings  ${resp.json()['phoneVerified']}          ${bool[0]} 

    ${resp}=   Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    comment   WAITLISTADD
    Should Be Equal As Strings  ${resp.json()[0]['resourceType']}    ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['eventType']}      ${EventType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['email'][0]}       ${email}
    Should Be Equal As Strings  ${resp.json()[0]['sms'][0]['number']}           ${PUSERNAME3} 
    Should Be Equal As Strings  ${resp.json()[0]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]['number']}       ${PUSERNAME3} 
    Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[0]['sms'][0]}        ${PUSERNAME3}
    # Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]}    ${PUSERNAME3}
    comment   WAITLIST-CANCEL
    Should Be Equal As Strings  ${resp.json()[1]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[1]['eventType']}     ${EventType[1]}
    Should Be Equal As Strings  ${resp.json()[1]['email'][0]}      ${email}
    Should Be Equal As Strings  ${resp.json()[1]['sms'][0]['number']}           ${PUSERNAME3} 
    Should Be Equal As Strings  ${resp.json()[1]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]['number']}       ${PUSERNAME3} 
    Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[1]['sms'][0]}        ${PUSERNAME3}
    # Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]}     ${PUSERNAME3}
    comment   APPOINTMENTADD
    Should Be Equal As Strings  ${resp.json()[2]['resourceType']}   ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[2]['eventType']}      ${EventType[7]}
    Should Be Equal As Strings  ${resp.json()[2]['email'][0]}       ${email}
    Should Be Equal As Strings  ${resp.json()[2]['sms'][0]['number']}           ${PUSERNAME3} 
    Should Be Equal As Strings  ${resp.json()[2]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]['number']}       ${PUSERNAME3} 
    Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[2]['sms'][0]}        ${PUSERNAME3}
    # Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]}    ${PUSERNAME3}
    comment   APPOINTMENT-CANCEL
    Should Be Equal As Strings  ${resp.json()[3]['resourceType']}    ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[3]['eventType']}       ${EventType[8]}
    Should Be Equal As Strings  ${resp.json()[3]['email'][0]}        ${email}
    Should Be Equal As Strings  ${resp.json()[3]['sms'][0]['number']}           ${PUSERNAME3} 
    Should Be Equal As Strings  ${resp.json()[3]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]['number']}       ${PUSERNAME3} 
    Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[3]['sms'][0]}          ${PUSERNAME3}
    # Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]}       ${PUSERNAME3}
    comment   DONATION
    Should Be Equal As Strings  ${resp.json()[4]['resourceType']}  ${NotificationResourceType[3]}
    Should Be Equal As Strings  ${resp.json()[4]['eventType']}     ${EventType[10]}
    Should Be Equal As Strings  ${resp.json()[4]['email'][0]}      ${email}
    Should Be Equal As Strings  ${resp.json()[4]['sms'][0]['number']}           ${PUSERNAME3} 
    Should Be Equal As Strings  ${resp.json()[4]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[4]['pushMsg'][0]['number']}       ${PUSERNAME3} 
    Should Be Equal As Strings  ${resp.json()[4]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[4]['sms'][0]}        ${PUSERNAME3}
    # Should Be Equal As Strings  ${resp.json()[4]['pushMsg'][0]}    ${PUSERNAME3}
    comment   LICENSE
    Should Be Equal As Strings  ${resp.json()[5]['resourceType']}    ${NotificationResourceType[2]}
    Should Be Equal As Strings  ${resp.json()[5]['eventType']}       ${EventType[9]}
    Should Be Equal As Strings  ${resp.json()[5]['email'][0]}        ${email}
    Should Be Equal As Strings  ${resp.json()[5]['sms'][0]['number']}           ${PUSERNAME3} 
    Should Be Equal As Strings  ${resp.json()[5]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[5]['pushMsg'][0]['number']}       ${PUSERNAME3} 
    Should Be Equal As Strings  ${resp.json()[5]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[5]['sms'][0]}          ${PUSERNAME3}
    # Should Be Equal As Strings  ${resp.json()[5]['pushMsg'][0]}      ${PUSERNAME3}

    ${firstname1}=  FakerLibrary.first_name
    ${lastname1}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}=  Random Element    ${Genderlist}
    Set Test Variable  ${email1}  ${firstname1}${PUSERNAME3}${C_Email}.${test_mail}
    ${resp}=   Update Service Provider With Emailid    ${pro_id2}  ${firstName1}  ${lastName1}  ${gender}  ${dob}  ${email1}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Provider Details    ${pro_id2} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['basicInfo']['id']}          ${pro_id2}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['firstName']}   ${firstname1}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['lastName']}    ${lastname1}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['mobile']}      ${PUSERNAME3}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['email']}        ${email1}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['emailVerified']}   ${bool[1]} 
    Should Be Equal As Strings  ${resp.json()['basicInfo']['phoneVerified']}   ${bool[0]} 

    ${resp}=   Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    # comment   LICENSE
    # Should Be Equal As Strings  ${resp.json()[4]['resourceType']}  ${NotificationResourceType[2]}
    # Should Be Equal As Strings  ${resp.json()[4]['eventType']}  ${EventType[9]}
    # Should Be Equal As Strings  ${resp.json()[4]['email'][0]}  ${email1}
    # Should Be Equal As Strings  ${resp.json()[4]['sms'][0]}  ${PUSERNAME3}
    # Should Be Equal As Strings  ${resp.json()[4]['pushMsg'][0]}  ${PUSERNAME3}

    ${resp}=  Get Account contact information
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['account']}             ${pid0}
    Should Be Equal As Strings  ${resp.json()['primaryPhoneNumber']}  ${PUSERNAME3}
    Should Be Equal As Strings  ${resp.json()['contactFirstName']}    ${firstname1}
    Should Be Equal As Strings  ${resp.json()['contactLastName']}     ${lastname1}
    Should Be Equal As Strings  ${resp.json()['primaryEmail']}         ${email1}
    Should Be Equal As Strings  ${resp.json()['emailVerified']}        ${bool[0]} 
    Should Be Equal As Strings  ${resp.json()['phoneVerified']}        ${bool[0]} 

JD-TC-Get Account Contact information-6
	[Documentation]  Get account contact information with  branch signup through phonenumber
    ${iscorp_subdomains}=  get_iscorp_subdomains  1
    Log  ${iscorp_subdomains}
    Set Suite Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
    Set Suite Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
    Set Suite Variable  ${sub_domain_id}   ${iscorp_subdomains[0]['subdomainId']}
    ${firstname_A}=  FakerLibrary.first_name
    Set Suite Variable  ${firstname_A}
    ${lastname_A}=  FakerLibrary.last_name
    Set Suite Variable  ${lastname_A}
    ${MUSERNAME_K}=  Evaluate  ${MUSERNAME}+405211222
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
    Set Test Variable  ${pro_id3}  ${resp.json()['id']}
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${MUSERNAME_K}${\n}
    Set Suite Variable  ${MUSERNAME_K}
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${MUSERNAME_K}${\n}
    ${pid3}=  get_acc_id  ${MUSERNAME_K}  
    ${resp}=  Get Account contact information
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['account']}              ${pid3}
    Should Be Equal As Strings  ${resp.json()['primaryPhoneNumber']}  ${MUSERNAME_K}
    Should Be Equal As Strings  ${resp.json()['contactFirstName']}    ${firstname_A}
    Should Be Equal As Strings  ${resp.json()['contactLastName']}      ${lastname_A}
    Should Be Equal As Strings  ${resp.json()['emailVerified']}        ${bool[0]} 
    Should Be Equal As Strings  ${resp.json()['phoneVerified']}        ${bool[1]} 

    ${resp}=  Get Provider Details    ${pro_id3} 
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['basicInfo']['id']}           ${pro_id3}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['firstName']}    ${firstname_A}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['lastName']}     ${lastname_A}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['mobile']}        ${MUSERNAME_K}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['emailVerified']}   ${bool[0]} 
    Should Be Equal As Strings  ${resp.json()['basicInfo']['phoneVerified']}   ${bool[1]} 

    ${resp}=   Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    comment   WAITLISTADD
    Should Be Equal As Strings  ${resp.json()[0]['resourceType']}     ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['eventType']}        ${EventType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['email']}            []
    Should Be Equal As Strings  ${resp.json()[0]['sms'][0]['number']}           ${MUSERNAME_K} 
    Should Be Equal As Strings  ${resp.json()[0]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]['number']}       ${MUSERNAME_K} 
    Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[0]['sms'][0]}           ${MUSERNAME_K}
    # Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]}       ${MUSERNAME_K}
    comment   WAITLIST-CANCEL
    Should Be Equal As Strings  ${resp.json()[1]['resourceType']}    ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[1]['eventType']}       ${EventType[1]}
    Should Be Equal As Strings  ${resp.json()[1]['email']}            []
    Should Be Equal As Strings  ${resp.json()[1]['sms'][0]['number']}           ${MUSERNAME_K} 
    Should Be Equal As Strings  ${resp.json()[1]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]['number']}       ${MUSERNAME_K} 
    Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[1]['sms'][0]}         ${MUSERNAME_K}
    # Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]}     ${MUSERNAME_K}
    comment   APPOINTMENTADD
    Should Be Equal As Strings  ${resp.json()[2]['resourceType']}    ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[2]['eventType']}       ${EventType[7]}
    Should Be Equal As Strings  ${resp.json()[2]['email']}           []
    Should Be Equal As Strings  ${resp.json()[2]['sms'][0]['number']}           ${MUSERNAME_K} 
    Should Be Equal As Strings  ${resp.json()[2]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]['number']}       ${MUSERNAME_K} 
    Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[2]['sms'][0]}           ${MUSERNAME_K}
    # Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]}       ${MUSERNAME_K}
    comment   APPOINTMENT-CANCEL
    Should Be Equal As Strings  ${resp.json()[3]['resourceType']}     ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[3]['eventType']}         ${EventType[8]}
    Should Be Equal As Strings  ${resp.json()[3]['email']}             []
    Should Be Equal As Strings  ${resp.json()[3]['sms'][0]['number']}           ${MUSERNAME_K} 
    Should Be Equal As Strings  ${resp.json()[3]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]['number']}       ${MUSERNAME_K} 
    Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[3]['sms'][0]}            ${MUSERNAME_K}
    # Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]}        ${MUSERNAME_K}
    comment   DONATION
    Should Be Equal As Strings  ${resp.json()[4]['resourceType']}     ${NotificationResourceType[3]}
    Should Be Equal As Strings  ${resp.json()[4]['eventType']}       ${EventType[10]}
    Should Be Equal As Strings  ${resp.json()[4]['email']}           []
    Should Be Equal As Strings  ${resp.json()[4]['sms'][0]['number']}           ${MUSERNAME_K} 
    Should Be Equal As Strings  ${resp.json()[4]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[4]['pushMsg'][0]['number']}       ${MUSERNAME_K} 
    Should Be Equal As Strings  ${resp.json()[4]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[4]['sms'][0]}          ${MUSERNAME_K}
    # Should Be Equal As Strings  ${resp.json()[4]['pushMsg'][0]}      ${MUSERNAME_K}
    comment   LICENSE
    Should Be Equal As Strings  ${resp.json()[5]['resourceType']}    ${NotificationResourceType[2]}
    Should Be Equal As Strings  ${resp.json()[5]['eventType']}       ${EventType[9]}
    Should Be Equal As Strings  ${resp.json()[5]['email']}           []
    Should Be Equal As Strings  ${resp.json()[5]['sms'][0]['number']}           ${MUSERNAME_K} 
    Should Be Equal As Strings  ${resp.json()[5]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[5]['pushMsg'][0]['number']}       ${MUSERNAME_K} 
    Should Be Equal As Strings  ${resp.json()[5]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[5]['sms'][0]}          ${MUSERNAME_K}
    # Should Be Equal As Strings  ${resp.json()[5]['pushMsg'][0]}      ${MUSERNAME_K}

    ${firstname1}=  FakerLibrary.first_name
    ${lastname1}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}=  Random Element    ${Genderlist}
    Set Test Variable  ${email}  ${firstname1}${PUSERNAME0}${C_Email}.${test_mail}
    ${resp}=   Update Service Provider With Emailid    ${pro_id3}  ${firstName1}  ${lastName1}  ${gender}  ${dob}  ${email}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Provider Details    ${pro_id3} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['basicInfo']['id']}            ${pro_id3}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['firstName']}     ${firstname1}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['lastName']}      ${lastname1}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['mobile']}        ${MUSERNAME_K}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['email']}         ${email}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['emailVerified']}   ${bool[1]} 
    Should Be Equal As Strings  ${resp.json()['basicInfo']['phoneVerified']}   ${bool[1]} 

    ${resp}=   Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
     comment   WAITLISTADD
    Should Be Equal As Strings  ${resp.json()[0]['resourceType']}    ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['eventType']}       ${EventType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['email']}            []
    Should Be Equal As Strings  ${resp.json()[0]['sms'][0]['number']}           ${MUSERNAME_K} 
    Should Be Equal As Strings  ${resp.json()[0]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]['number']}       ${MUSERNAME_K} 
    Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[0]['sms'][0]}          ${MUSERNAME_K}
    # Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]}       ${MUSERNAME_K}
    comment   WAITLIST-CANCEL
    Should Be Equal As Strings  ${resp.json()[1]['resourceType']}    ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[1]['eventType']}       ${EventType[1]}
    Should Be Equal As Strings  ${resp.json()[1]['email']}            []
    Should Be Equal As Strings  ${resp.json()[1]['sms'][0]['number']}           ${MUSERNAME_K} 
    Should Be Equal As Strings  ${resp.json()[1]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]['number']}       ${MUSERNAME_K} 
    Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[1]['sms'][0]}          ${MUSERNAME_K}
    # Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]}      ${MUSERNAME_K}
    comment   APPOINTMENTADD
    Should Be Equal As Strings  ${resp.json()[2]['resourceType']}   ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[2]['eventType']}      ${EventType[7]}
    Should Be Equal As Strings  ${resp.json()[2]['email']}          []
    Should Be Equal As Strings  ${resp.json()[2]['sms'][0]['number']}           ${MUSERNAME_K} 
    Should Be Equal As Strings  ${resp.json()[2]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]['number']}       ${MUSERNAME_K} 
    Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[2]['sms'][0]}         ${MUSERNAME_K}
    # Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]}      ${MUSERNAME_K}
    comment   APPOINTMENT-CANCEL
    Should Be Equal As Strings  ${resp.json()[3]['resourceType']}    ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[3]['eventType']}       ${EventType[8]}
    Should Be Equal As Strings  ${resp.json()[3]['email']}           []
    Should Be Equal As Strings  ${resp.json()[3]['sms'][0]['number']}           ${MUSERNAME_K} 
    Should Be Equal As Strings  ${resp.json()[3]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]['number']}       ${MUSERNAME_K} 
    Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[3]['sms'][0]}           ${MUSERNAME_K}
    # Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]}        ${MUSERNAME_K}
    comment   DONATION
    Should Be Equal As Strings  ${resp.json()[4]['resourceType']}  ${NotificationResourceType[3]}
    Should Be Equal As Strings  ${resp.json()[4]['eventType']}     ${EventType[10]}
    Should Be Equal As Strings  ${resp.json()[4]['email']}         []
    Should Be Equal As Strings  ${resp.json()[4]['sms'][0]['number']}           ${MUSERNAME_K} 
    Should Be Equal As Strings  ${resp.json()[4]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[4]['pushMsg'][0]['number']}       ${MUSERNAME_K} 
    Should Be Equal As Strings  ${resp.json()[4]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[4]['sms'][0]}        ${MUSERNAME_K}
    # Should Be Equal As Strings  ${resp.json()[4]['pushMsg'][0]}    ${MUSERNAME_K}
    comment   LICENSE
    Should Be Equal As Strings  ${resp.json()[5]['resourceType']}    ${NotificationResourceType[2]}
    Should Be Equal As Strings  ${resp.json()[5]['eventType']}       ${EventType[9]}
    Should Be Equal As Strings  ${resp.json()[5]['email']}           []
    Should Be Equal As Strings  ${resp.json()[5]['sms'][0]['number']}           ${MUSERNAME_K} 
    Should Be Equal As Strings  ${resp.json()[5]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[5]['pushMsg'][0]['number']}       ${MUSERNAME_K} 
    Should Be Equal As Strings  ${resp.json()[5]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[5]['sms'][0]}          ${MUSERNAME_K}
    # Should Be Equal As Strings  ${resp.json()[5]['pushMsg'][0]}      ${MUSERNAME_K}

    ${resp}=  Get Account contact information
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['account']}             ${pid3}
    Should Be Equal As Strings  ${resp.json()['primaryPhoneNumber']}  ${MUSERNAME_K}
    Should Be Equal As Strings  ${resp.json()['contactFirstName']}    ${firstname1}
    Should Be Equal As Strings  ${resp.json()['contactLastName']}     ${lastname1}
    Should Be Equal As Strings  ${resp.json()['emailVerified']}       ${bool[0]} 
    Should Be Equal As Strings  ${resp.json()['phoneVerified']}       ${bool[1]} 
    # Should Not Contain          ${resp.json()['contactFirstName']}  ${firstname1}
    # Should Not Contain          ${resp.json()['contactLastName']}   ${lastname1}
    
JD-TC-Get Account Contact information-7
	[Documentation]  Get account contact information with  branch signup through phonenumber and create user
    # ${iscorp_subdomains}=  get_iscorp_subdomains  1
    # Log  ${iscorp_subdomains}
    # Set Suite Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
    # Set Suite Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
    # Set Suite Variable  ${sub_domain_id}   ${iscorp_subdomains[0]['subdomainId']}

    # ${resp}=  Encrypted Provider Login   ${MUSERNAME0}  ${PASSWORD}
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # Set Suite Variable  ${subdomain}  ${resp.json()['subSector']}


    ${firstname_B}=  FakerLibrary.first_name
    ${lastname_B}=  FakerLibrary.last_name
    ${MUSERNAME_L}=  Evaluate  ${MUSERNAME}+405314222
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
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${MUSERNAME_L}${\n}
    Set Suite Variable  ${MUSERNAME_L}
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${MUSERNAME_L}${\n}
    ${pid4}=  get_acc_id  ${MUSERNAME_L}  
    ${resp}=  Get Account contact information
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['account']}            ${pid4}
    Should Be Equal As Strings  ${resp.json()['primaryPhoneNumber']}  ${MUSERNAME_L}
    Should Be Equal As Strings  ${resp.json()['contactFirstName']}  ${firstname_B}
    Should Be Equal As Strings  ${resp.json()['contactLastName']}   ${lastname_B}
    Should Be Equal As Strings  ${resp.json()['emailVerified']}     ${bool[0]} 
    Should Be Equal As Strings  ${resp.json()['phoneVerified']}     ${bool[1]}

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
    ${PUSERNAME_U1}=  Evaluate  ${PUSERNAME}+336835
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
    Set Test Variable  ${city}   ${resp.json()[0]['PostOffice'][0]['District']}   
    Set Test Variable  ${state}  ${resp.json()[0]['PostOffice'][0]['State']}      
    Set Test Variable  ${pin2}    ${resp.json()[0]['PostOffice'][0]['Pincode']}    


    ${whpnum}=  Evaluate  ${PUSERNAME_U1}+335243
    ${tlgnum}=  Evaluate  ${PUSERNAME_U1}+335143

    ${resp}=  Create User  ${firstname2}  ${lastname2}  ${dob2}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U1}.${test_mail}   ${userType[0]}  ${pin2}  ${countryCodes[0]}  ${PUSERNAME_U1}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${countryCodes[0]}  ${whpnum}  ${countryCodes[0]}  ${tlgnum}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${u_id}  ${resp.json()}
    ${resp}=  Get User By Id  ${u_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response  ${resp}  id=${u_id}  firstName=${firstname2}  lastName=${lastname2}  mobileNo=${PUSERNAME_U1}  dob=${dob2}  gender=${Genderlist[0]}  userType=${userType[0]}  status=ACTIVE  email=${P_Email}${PUSERNAME_U1}.${test_mail}  city=${city}  state=${state}  deptId=${dep_id}  subdomain=${userSubDomain}
    Verify Response  ${resp}  id=${u_id}  firstName=${firstname2}  lastName=${lastname2}  mobileNo=${PUSERNAME_U1}  dob=${dob2}  gender=${Genderlist[0]}  userType=${userType[0]}  pincode=${pin2}  status=ACTIVE  email=${P_Email}${PUSERNAME_U1}.${test_mail}  deptId=${dep_id}  subdomain=${userSubDomain}

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
    Set Suite Variable   ${p1_id}   ${resp.json()[0]['id']}

    ${resp}=  Get Notification Settings of User  ${p1_id}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    comment   WAITLISTADD
    Should Be Equal As Strings  ${resp.json()[0]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['eventType']}     ${EventType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['email'][0]}      ${P_Email}${PUSERNAME_U1}.${test_mail}
    Should Be Equal As Strings  ${resp.json()[0]['sms'][0]['number']}           ${PUSERNAME_U1} 
    Should Be Equal As Strings  ${resp.json()[0]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]['number']}       ${PUSERNAME_U1} 
    Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[0]['sms'][0]}        ${PUSERNAME_U1}
    # Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]}    ${PUSERNAME_U1}
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
    Should Be Equal As Strings  ${resp.json()[2]['eventType']}     ${EventType[7]}
    Should Be Equal As Strings  ${resp.json()[2]['email'][0]}      ${P_Email}${PUSERNAME_U1}.${test_mail}
    Should Be Equal As Strings  ${resp.json()[2]['sms'][0]['number']}           ${PUSERNAME_U1} 
    Should Be Equal As Strings  ${resp.json()[2]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]['number']}       ${PUSERNAME_U1} 
    Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[2]['sms'][0]}        ${PUSERNAME_U1}
    # Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]}    ${PUSERNAME_U1}
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
    

JD-TC-Get Account Contact information-8
    [Documentation]  Get account contact information of a existing provider
    ${resp}=  Encrypted Provider Login  ${PUSERNAME15}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${pro_id4}  ${resp.json()['id']}
    Set Test Variable    ${first-name}    ${resp.json()['firstName']}  
    Set Test Variable    ${last-name}     ${resp.json()['lastName']} 
    ${pid4}=  get_acc_id  ${PUSERNAME15}  
    ${resp}=  Get Account contact information
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['account']}            ${pid4}
    Should Be Equal As Strings  ${resp.json()['primaryPhoneNumber']}  ${PUSERNAME15}
    Should Be Equal As Strings  ${resp.json()['contactFirstName']}   ${first-name}
    Should Be Equal As Strings  ${resp.json()['contactLastName']}    ${last-name}
    Should Be Equal As Strings  ${resp.json()['emailVerified']}      ${bool[0]} 
    Should Be Equal As Strings  ${resp.json()['phoneVerified']}      ${bool[1]} 

    ${firstname1}=  FakerLibrary.first_name
    ${lastname1}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}=  Random Element    ${Genderlist}
    Set Suite Variable  ${email_L}  ${firstname1}${PUSERNAME15}${C_Email}.${test_mail}
    ${resp}=   Update Service Provider With Emailid    ${pro_id4}  ${firstName1}  ${lastName1}  ${gender}  ${dob}  ${email_L}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Account contact information
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['account']}            ${pid4}
    Should Be Equal As Strings  ${resp.json()['primaryPhoneNumber']}  ${PUSERNAME15}
    Should Be Equal As Strings  ${resp.json()['contactFirstName']}   ${firstname1}
    Should Be Equal As Strings  ${resp.json()['contactLastName']}    ${lastname1}
    # Should Be Equal As Strings  ${resp.json()['primaryEmail']}  ${email_L}
    Should Be Equal As Strings  ${resp.json()['emailVerified']}      ${bool[0]} 
    Should Be Equal As Strings  ${resp.json()['phoneVerified']}      ${bool[1]} 

    ${resp}=   Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-Get Account Contact information-UH1
    [Documentation]  Get account contact information of a existing provider and update provider details with used email
    ${resp}=  Encrypted Provider Login  ${PUSERNAME16}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${pro_id5}  ${resp.json()['id']}
    Set Test Variable    ${first-name}    ${resp.json()['firstName']}  
    Set Test Variable    ${last-name}     ${resp.json()['lastName']} 
    ${pid5}=  get_acc_id  ${PUSERNAME16}  
    ${resp}=  Get Account contact information
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['account']}             ${pid5}
    Should Be Equal As Strings  ${resp.json()['primaryPhoneNumber']}  ${PUSERNAME16}
    Should Be Equal As Strings  ${resp.json()['contactFirstName']}    ${first-name}
    Should Be Equal As Strings  ${resp.json()['contactLastName']}     ${last-name}
    Should Be Equal As Strings  ${resp.json()['emailVerified']}       ${bool[0]} 
    Should Be Equal As Strings  ${resp.json()['phoneVerified']}       ${bool[1]} 

    ${firstname1}=  FakerLibrary.first_name
    ${lastname1}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}=  Random Element    ${Genderlist}
    ${resp}=   Update Service Provider With Emailid    ${pro_id5}  ${firstName1}  ${lastName1}  ${gender}  ${dob}  ${email_L}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings   ${resp.json()}    ${EMAIL_EXISTS}

JD-TC-Get Account Contact information-UH2
    [Documentation]   Get account contact information without provider login
    ${resp}=  Get Account contact information
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings   ${resp.json()}    ${SESSION_EXPIRED}
    
JD-TC-Get Account Contact information-UH3
    [Documentation]   Get account contact information using consumer login
    ${resp}=   Consumer Login  ${CUSERNAME1}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Get Account contact information
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"  


    