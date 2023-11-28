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
JD-TC-Update Email-1
    [Documentation]  Update email  with  signup through primaryphonenumber
    ${domresp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${domresp.status_code}  200
    ${len}=  Get Length  ${domresp.json()}
    ${len}=  Evaluate  ${len}-1
    ${PUSERNAME}=  Evaluate  ${PUSERNAME}+407013222
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
    Set Suite Variable  ${pro_id}  ${resp.json()['id']}
    Set Test Variable  ${PUSERNAME}
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERNAME}${\n}  
    ${pid}=  get_acc_id  ${PUSERNAME}
    ${resp}=  Get Provider Details    ${pro_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['id']}              ${pro_id}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['firstName']}       ${firstname}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['lastName']}        ${lastname}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['mobile']}          ${PUSERNAME}
    # Should Be Equal As Strings  ${resp.json()['basicInfo']['emailVerified']}   ${bool[0]} 
    # Should Be Equal As Strings  ${resp.json()['basicInfo']['phoneVerified']}   ${bool[1]} 

    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${email}  ${firstname}${PUSERNAME}${C_Email}.${test_mail}
    ${resp}=  Update Email   ${pro_id}   ${firstname}   ${lastname}   ${email}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Get Provider Details    ${pro_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['basicInfo']['id']}              ${pro_id}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['firstName']}       ${firstname}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['lastName']}        ${lastname}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['mobile']}          ${PUSERNAME}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['email']}           ${email}
    # Should Be Equal As Strings  ${resp.json()['basicInfo']['emailVerified']}   ${bool[1]} 
    # Should Be Equal As Strings  ${resp.json()['basicInfo']['phoneVerified']}   ${bool[1]} 

    ${resp}=  Get Account contact information
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['account']}             ${pid}
    Should Be Equal As Strings  ${resp.json()['primaryPhoneNumber']}  ${PUSERNAME}
    Should Be Equal As Strings  ${resp.json()['contactFirstName']}    ${firstname}
    Should Be Equal As Strings  ${resp.json()['contactLastName']}     ${lastname}
    Should Be Equal As Strings  ${resp.json()['primaryEmail']}        ${email}
    Should Be Equal As Strings  ${resp.json()['emailVerified']}       ${bool[0]} 
    Should Be Equal As Strings  ${resp.json()['phoneVerified']}       ${bool[1]} 

    Set Suite Variable  ${countryCode_CC0}    ${countryCodes[0]}
    ${resp}=   Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    comment   WAITLISTADD
    Should Be Equal As Strings  ${resp.json()[0]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['eventType']}   ${EventType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['email'][0]}    ${email}
    Should Be Equal As Strings  ${resp.json()[0]['sms'][0]['number']}           ${PUSERNAME} 
    Should Be Equal As Strings  ${resp.json()[0]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]['number']}       ${PUSERNAME} 
    Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[0]['sms'][0]}      ${PUSERNAME}
    # Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]}  ${PUSERNAME}
    comment   WAITLIST-CANCEL
    Should Be Equal As Strings  ${resp.json()[1]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[1]['eventType']}    ${EventType[1]}
    Should Be Equal As Strings  ${resp.json()[1]['email'][0]}     ${email}
    Should Be Equal As Strings  ${resp.json()[1]['sms'][0]['number']}           ${PUSERNAME} 
    Should Be Equal As Strings  ${resp.json()[1]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]['number']}       ${PUSERNAME} 
    Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[1]['sms'][0]}       ${PUSERNAME}
    # Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]}   ${PUSERNAME}
    comment   APPOINTMENTADD
    Should Be Equal As Strings  ${resp.json()[2]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[2]['eventType']}    ${EventType[7]}
    Should Be Equal As Strings  ${resp.json()[2]['email'][0]}     ${email}
    Should Be Equal As Strings  ${resp.json()[2]['sms'][0]['number']}           ${PUSERNAME} 
    Should Be Equal As Strings  ${resp.json()[2]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]['number']}       ${PUSERNAME} 
    Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[2]['sms'][0]}       ${PUSERNAME}
    # Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]}   ${PUSERNAME}
    comment   APPOINTMENT-CANCEL
    Should Be Equal As Strings  ${resp.json()[3]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[3]['eventType']}     ${EventType[8]}
    Should Be Equal As Strings  ${resp.json()[3]['email'][0]}      ${email}
    Should Be Equal As Strings  ${resp.json()[3]['sms'][0]['number']}           ${PUSERNAME} 
    Should Be Equal As Strings  ${resp.json()[3]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]['number']}       ${PUSERNAME} 
    Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[3]['sms'][0]}        ${PUSERNAME}
    # Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]}    ${PUSERNAME}
    comment   DONATION
    Should Be Equal As Strings  ${resp.json()[4]['resourceType']}  ${NotificationResourceType[3]}
    Should Be Equal As Strings  ${resp.json()[4]['eventType']}     ${EventType[10]}
    Should Be Equal As Strings  ${resp.json()[4]['email'][0]}      ${email}
    Should Be Equal As Strings  ${resp.json()[4]['sms'][0]['number']}           ${PUSERNAME} 
    Should Be Equal As Strings  ${resp.json()[4]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[4]['pushMsg'][0]['number']}       ${PUSERNAME} 
    Should Be Equal As Strings  ${resp.json()[4]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[4]['sms'][0]}        ${PUSERNAME}
    # Should Be Equal As Strings  ${resp.json()[4]['pushMsg'][0]}    ${PUSERNAME}
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

JD-TC-Update Email-2
	[Documentation]  Update email  with  signup through email and update with different email
    ${domresp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${domresp.status_code}  200
    ${len}=  Get Length  ${domresp.json()}
    ${len}=  Evaluate  ${len}-1
    ${PUSERNAME_0}=  Evaluate  ${PUSERNAME}+407014222
    Set Test Variable  ${d1}  ${domresp.json()[${len}]['domain']}    
    Set Test Variable  ${sd}  ${domresp.json()[${len}]['subDomains'][0]['subDomain']} 
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${highest_package}=  get_highest_license_pkg
    Set Suite Variable  ${e-mail}  ${firstname}${PUSERNAME_0}${C_Email}.${test_mail}
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${e-mail}  ${d1}  ${sd}  ${PUSERNAME_0}   ${highest_package[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${e-mail}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${e-mail}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${pro_id1}  ${resp.json()['id']}
    Set Suite Variable  ${PUSERNAME_0}
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERNAME_0}${\n}  
    ${pid}=  get_acc_id  ${PUSERNAME_0}
    ${resp}=  Get Provider Details    ${pro_id1} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['basicInfo']['id']}              ${pro_id1}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['firstName']}       ${firstname}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['lastName']}        ${lastname}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['mobile']}          ${PUSERNAME_0}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['email']}           ${e-mail}
    # Should Be Equal As Strings  ${resp.json()['basicInfo']['emailVerified']}   ${bool[1]} 
    # Should Be Equal As Strings  ${resp.json()['basicInfo']['phoneVerified']}   ${bool[0]} 

    ${firstname0}=  FakerLibrary.first_name
    Set Suite Variable  ${firstname0}
    ${lastname0}=  FakerLibrary.last_name
    Set Suite Variable   ${lastname0}
    Set Test Variable  ${email_0}  ${firstname0}${PUSERNAME_0}${C_Email}.${test_mail}
    ${resp}=  Update Email   ${pro_id1}   ${firstname0}   ${lastname0}   ${email_0}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Get Provider Details    ${pro_id1} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['basicInfo']['id']}              ${pro_id1}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['firstName']}       ${firstname0}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['lastName']}        ${lastname0}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['mobile']}          ${PUSERNAME_0}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['email']}           ${email_0}
    # Should Be Equal As Strings  ${resp.json()['basicInfo']['emailVerified']}   ${bool[1]} 
    # Should Be Equal As Strings  ${resp.json()['basicInfo']['phoneVerified']}   ${bool[0]} 

    ${resp}=  Get Account contact information
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['account']}             ${pid}
    Should Be Equal As Strings  ${resp.json()['primaryPhoneNumber']}  ${PUSERNAME_0}
    Should Be Equal As Strings  ${resp.json()['contactFirstName']}    ${firstname0}
    Should Be Equal As Strings  ${resp.json()['contactLastName']}     ${lastname0}
    Should Be Equal As Strings  ${resp.json()['primaryEmail']}        ${email_0}
    Should Be Equal As Strings  ${resp.json()['emailVerified']}       ${bool[0]} 
    Should Be Equal As Strings  ${resp.json()['phoneVerified']}       ${bool[0]} 

    ${resp}=   Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    comment   WAITLISTADD
    Should Be Equal As Strings  ${resp.json()[0]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['eventType']}   ${EventType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['email'][0]}    ${email_0}
    Should Be Equal As Strings  ${resp.json()[0]['sms'][0]['number']}           ${PUSERNAME_0} 
    Should Be Equal As Strings  ${resp.json()[0]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]['number']}       ${PUSERNAME_0} 
    Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[0]['sms'][0]}      ${PUSERNAME_0}
    # Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]}  ${PUSERNAME_0}
    comment   WAITLIST-CANCEL
    Should Be Equal As Strings  ${resp.json()[1]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[1]['eventType']}    ${EventType[1]}
    Should Be Equal As Strings  ${resp.json()[1]['email'][0]}     ${email_0}
    Should Be Equal As Strings  ${resp.json()[1]['sms'][0]['number']}           ${PUSERNAME_0} 
    Should Be Equal As Strings  ${resp.json()[1]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]['number']}       ${PUSERNAME_0} 
    Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[1]['sms'][0]}       ${PUSERNAME_0}
    # Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]}   ${PUSERNAME_0}
    comment   APPOINTMENTADD
    Should Be Equal As Strings  ${resp.json()[2]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[2]['eventType']}    ${EventType[7]}
    Should Be Equal As Strings  ${resp.json()[2]['email'][0]}     ${email_0}
    Should Be Equal As Strings  ${resp.json()[2]['sms'][0]['number']}           ${PUSERNAME_0} 
    Should Be Equal As Strings  ${resp.json()[2]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]['number']}       ${PUSERNAME_0} 
    Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[2]['sms'][0]}       ${PUSERNAME_0}
    # Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]}   ${PUSERNAME_0}
    comment   APPOINTMENT-CANCEL
    Should Be Equal As Strings  ${resp.json()[3]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[3]['eventType']}     ${EventType[8]}
    Should Be Equal As Strings  ${resp.json()[3]['email'][0]}      ${email_0}
    Should Be Equal As Strings  ${resp.json()[3]['sms'][0]['number']}           ${PUSERNAME_0} 
    Should Be Equal As Strings  ${resp.json()[3]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]['number']}       ${PUSERNAME_0} 
    Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[3]['sms'][0]}        ${PUSERNAME_0}
    # Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]}    ${PUSERNAME_0}
    comment   DONATION
    Should Be Equal As Strings  ${resp.json()[4]['resourceType']}  ${NotificationResourceType[3]}
    Should Be Equal As Strings  ${resp.json()[4]['eventType']}     ${EventType[10]}
    Should Be Equal As Strings  ${resp.json()[4]['email'][0]}      ${email_0}
    Should Be Equal As Strings  ${resp.json()[4]['sms'][0]['number']}           ${PUSERNAME_0} 
    Should Be Equal As Strings  ${resp.json()[4]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[4]['pushMsg'][0]['number']}       ${PUSERNAME_0} 
    Should Be Equal As Strings  ${resp.json()[4]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[4]['sms'][0]}        ${PUSERNAME_0}
    # Should Be Equal As Strings  ${resp.json()[4]['pushMsg'][0]}    ${PUSERNAME_0}
    comment   LICENSE
    Should Be Equal As Strings  ${resp.json()[5]['resourceType']}  ${NotificationResourceType[2]}
    Should Be Equal As Strings  ${resp.json()[5]['eventType']}     ${EventType[9]}
    Should Be Equal As Strings  ${resp.json()[5]['email'][0]}      ${email_0}
    Should Be Equal As Strings  ${resp.json()[5]['sms'][0]['number']}           ${PUSERNAME_0} 
    Should Be Equal As Strings  ${resp.json()[5]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[5]['pushMsg'][0]['number']}       ${PUSERNAME_0} 
    Should Be Equal As Strings  ${resp.json()[5]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[5]['sms'][0]}        ${PUSERNAME_0}
    # Should Be Equal As Strings  ${resp.json()[5]['pushMsg'][0]}    ${PUSERNAME_0}


JD-TC-Update Email-3
	[Documentation]  Update email with  branch signup through phonenumber
    ${iscorp_subdomains}=  get_iscorp_subdomains  1
    Log  ${iscorp_subdomains}
    Set Suite Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
    Set Suite Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
    Set Suite Variable  ${sub_domain_id}   ${iscorp_subdomains[0]['subdomainId']}
    ${firstname_A}=  FakerLibrary.first_name
    ${lastname_A}=  FakerLibrary.last_name
    ${MUSERNAME_K}=  Evaluate  ${MUSERNAME}+407015222
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
    Set Test Variable  ${pro_id2}  ${resp.json()['id']}
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${MUSERNAME_K}${\n}
    Set Suite Variable  ${MUSERNAME_K}
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${MUSERNAME_K}${\n}
    ${pid2}=  get_acc_id  ${MUSERNAME_K}
    ${resp}=  Get Provider Details    ${pro_id2} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['basicInfo']['id']}              ${pro_id2}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['firstName']}       ${firstname_A}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['lastName']}        ${lastname_A}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['mobile']}          ${MUSERNAME_K}
    # Should Be Equal As Strings  ${resp.json()['basicInfo']['emailVerified']}   ${bool[0]} 
    # Should Be Equal As Strings  ${resp.json()['basicInfo']['phoneVerified']}   ${bool[1]} 

    ${resp}=  Get Account contact information
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['account']}             ${pid2}
    Should Be Equal As Strings  ${resp.json()['primaryPhoneNumber']}  ${MUSERNAME_K}
    Should Be Equal As Strings  ${resp.json()['contactFirstName']}    ${firstname_A}
    Should Be Equal As Strings  ${resp.json()['contactLastName']}     ${lastname_A}
    Should Be Equal As Strings  ${resp.json()['emailVerified']}       ${bool[0]} 
    Should Be Equal As Strings  ${resp.json()['phoneVerified']}       ${bool[1]} 

    ${firstname1}=  FakerLibrary.first_name
    ${lastname1}=  FakerLibrary.last_name
    Set Test Variable  ${email_1}  ${firstname1}${MUSERNAME_K}${C_Email}.${test_mail}
    ${resp}=  Update Email   ${pro_id2}   ${firstname1}   ${lastname1}   ${email_1}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Provider Details    ${pro_id2} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['basicInfo']['id']}              ${pro_id2}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['firstName']}       ${firstname1}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['lastName']}        ${lastname1}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['mobile']}          ${MUSERNAME_K}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['email']}           ${email_1}
    # Should Be Equal As Strings  ${resp.json()['basicInfo']['emailVerified']}   ${bool[1]} 
    # Should Be Equal As Strings  ${resp.json()['basicInfo']['phoneVerified']}   ${bool[1]} 

    ${resp}=  Get Account contact information
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['account']}                ${pid2}
    Should Be Equal As Strings  ${resp.json()['primaryPhoneNumber']}     ${MUSERNAME_K}
    Should Be Equal As Strings  ${resp.json()['contactFirstName']}       ${firstname1}
    Should Be Equal As Strings  ${resp.json()['contactLastName']}        ${lastname1}
    Should Be Equal As Strings  ${resp.json()['primaryEmail']}           ${email_1}
    Should Be Equal As Strings  ${resp.json()['emailVerified']}          ${bool[0]} 
    Should Be Equal As Strings  ${resp.json()['phoneVerified']}          ${bool[1]} 

    ${resp}=   Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    comment   WAITLISTADD
    Should Be Equal As Strings  ${resp.json()[0]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['eventType']}   ${EventType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['email'][0]}    ${email_1}
    Should Be Equal As Strings  ${resp.json()[0]['sms'][0]['number']}           ${MUSERNAME_K} 
    Should Be Equal As Strings  ${resp.json()[0]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]['number']}       ${MUSERNAME_K} 
    Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[0]['sms'][0]}      ${MUSERNAME_K}
    # Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]}  ${MUSERNAME_K}
    comment   WAITLIST-CANCEL
    Should Be Equal As Strings  ${resp.json()[1]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[1]['eventType']}    ${EventType[1]}
    Should Be Equal As Strings  ${resp.json()[1]['email'][0]}     ${email_1}
    Should Be Equal As Strings  ${resp.json()[1]['sms'][0]['number']}           ${MUSERNAME_K} 
    Should Be Equal As Strings  ${resp.json()[1]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]['number']}       ${MUSERNAME_K} 
    Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[1]['sms'][0]}       ${MUSERNAME_K}
    # Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]}   ${MUSERNAME_K}
    comment   APPOINTMENTADD
    Should Be Equal As Strings  ${resp.json()[2]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[2]['eventType']}    ${EventType[7]}
    Should Be Equal As Strings  ${resp.json()[2]['email'][0]}     ${email_1}
    Should Be Equal As Strings  ${resp.json()[2]['sms'][0]['number']}           ${MUSERNAME_K} 
    Should Be Equal As Strings  ${resp.json()[2]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]['number']}       ${MUSERNAME_K} 
    Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[2]['sms'][0]}       ${MUSERNAME_K}
    # Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]}   ${MUSERNAME_K}
    comment   APPOINTMENT-CANCEL
    Should Be Equal As Strings  ${resp.json()[3]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[3]['eventType']}     ${EventType[8]}
    Should Be Equal As Strings  ${resp.json()[3]['email'][0]}      ${email_1}
    Should Be Equal As Strings  ${resp.json()[3]['sms'][0]['number']}           ${MUSERNAME_K} 
    Should Be Equal As Strings  ${resp.json()[3]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]['number']}       ${MUSERNAME_K} 
    Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[3]['sms'][0]}        ${MUSERNAME_K}
    # Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]}    ${MUSERNAME_K}
    comment   DONATION
    Should Be Equal As Strings  ${resp.json()[4]['resourceType']}  ${NotificationResourceType[3]}
    Should Be Equal As Strings  ${resp.json()[4]['eventType']}     ${EventType[10]}
    Should Be Equal As Strings  ${resp.json()[4]['email'][0]}      ${email_1}
    Should Be Equal As Strings  ${resp.json()[4]['sms'][0]['number']}           ${MUSERNAME_K} 
    Should Be Equal As Strings  ${resp.json()[4]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[4]['pushMsg'][0]['number']}       ${MUSERNAME_K} 
    Should Be Equal As Strings  ${resp.json()[4]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[4]['sms'][0]}        ${MUSERNAME_K}
    # Should Be Equal As Strings  ${resp.json()[4]['pushMsg'][0]}    ${MUSERNAME_K}
    comment   LICENSE
    Should Be Equal As Strings  ${resp.json()[5]['resourceType']}  ${NotificationResourceType[2]}
    Should Be Equal As Strings  ${resp.json()[5]['eventType']}     ${EventType[9]}
    Should Be Equal As Strings  ${resp.json()[5]['email'][0]}      ${email_1}
    Should Be Equal As Strings  ${resp.json()[5]['sms'][0]['number']}           ${MUSERNAME_K} 
    Should Be Equal As Strings  ${resp.json()[5]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[5]['pushMsg'][0]['number']}       ${MUSERNAME_K} 
    Should Be Equal As Strings  ${resp.json()[5]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[5]['sms'][0]}        ${MUSERNAME_K}
    # Should Be Equal As Strings  ${resp.json()[5]['pushMsg'][0]}    ${MUSERNAME_K}


JD-TC-Update Email-4
	[Documentation]  Update email with  branch signup through email
    ${iscorp_subdomains}=  get_iscorp_subdomains  1
    Log  ${iscorp_subdomains}
    Set Suite Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
    Set Suite Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
    Set Suite Variable  ${sub_domain_id}   ${iscorp_subdomains[0]['subdomainId']}
    ${firstname_B}=  FakerLibrary.first_name
    ${lastname_B}=  FakerLibrary.last_name
    ${MUSERNAME_L}=  Evaluate  ${MUSERNAME}+407016222
    ${highest_package}=  get_highest_license_pkg
    Set Test Variable  ${email_2}  ${firstname_B}${MUSERNAME_L}${C_Email}.${test_mail}
    ${resp}=  Account SignUp  ${firstname_B}  ${lastname_B}  ${email_2}  ${domains}  ${sub_domains}  ${MUSERNAME_L}    ${highest_package[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${email_2}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${email_2}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Encrypted Provider Login  ${MUSERNAME_L}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${pro_id3}  ${resp.json()['id']}
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${MUSERNAME_L}${\n}
    Set Suite Variable  ${MUSERNAME_L}
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${MUSERNAME_L}${\n}
    ${pid3}=  get_acc_id  ${MUSERNAME_L}
    ${resp}=  Get Provider Details    ${pro_id3} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['basicInfo']['id']}              ${pro_id3}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['firstName']}       ${firstname_B}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['lastName']}        ${lastname_B}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['mobile']}          ${MUSERNAME_L}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['email']}           ${email_2}
    # Should Be Equal As Strings  ${resp.json()['basicInfo']['emailVerified']}   ${bool[1]} 
    # Should Be Equal As Strings  ${resp.json()['basicInfo']['phoneVerified']}   ${bool[0]} 

    ${resp}=  Get Account contact information
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${firstname1}=  FakerLibrary.first_name
    ${lastname1}=  FakerLibrary.last_name
    Set Suite Variable  ${email_1}  ${firstname1}${MUSERNAME_L}${C_Email}.${test_mail}
    ${resp}=  Update Email   ${pro_id3}   ${firstname1}   ${lastname1}   ${email_1}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Provider Details    ${pro_id3} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['basicInfo']['id']}              ${pro_id3}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['firstName']}       ${firstname1}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['lastName']}        ${lastname1}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['mobile']}          ${MUSERNAME_L}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['email']}           ${email_1}
    # Should Be Equal As Strings  ${resp.json()['basicInfo']['emailVerified']}   ${bool[1]} 
    # Should Be Equal As Strings  ${resp.json()['basicInfo']['phoneVerified']}   ${bool[0]} 

    ${resp}=  Get Account contact information
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['account']}                ${pid3}
    Should Be Equal As Strings  ${resp.json()['primaryPhoneNumber']}     ${MUSERNAME_L}
    Should Be Equal As Strings  ${resp.json()['contactFirstName']}       ${firstname1}
    Should Be Equal As Strings  ${resp.json()['contactLastName']}        ${lastname1}
    Should Be Equal As Strings  ${resp.json()['primaryEmail']}           ${email_1}
    Should Be Equal As Strings  ${resp.json()['emailVerified']}          ${bool[0]} 
    Should Be Equal As Strings  ${resp.json()['phoneVerified']}          ${bool[0]} 

    ${resp}=   Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    comment   WAITLISTADD
    Should Be Equal As Strings  ${resp.json()[0]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['eventType']}   ${EventType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['email'][0]}    ${email_1}
    Should Be Equal As Strings  ${resp.json()[0]['sms'][0]['number']}           ${MUSERNAME_L} 
    Should Be Equal As Strings  ${resp.json()[0]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]['number']}       ${MUSERNAME_L} 
    Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[0]['sms'][0]}      ${MUSERNAME_L}
    # Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]}  ${MUSERNAME_L}
    comment   WAITLIST-CANCEL
    Should Be Equal As Strings  ${resp.json()[1]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[1]['eventType']}    ${EventType[1]}
    Should Be Equal As Strings  ${resp.json()[1]['email'][0]}     ${email_1}
    Should Be Equal As Strings  ${resp.json()[1]['sms'][0]['number']}           ${MUSERNAME_L} 
    Should Be Equal As Strings  ${resp.json()[1]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]['number']}       ${MUSERNAME_L} 
    Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[1]['sms'][0]}       ${MUSERNAME_L}
    # Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]}   ${MUSERNAME_L}
    comment   APPOINTMENTADD
    Should Be Equal As Strings  ${resp.json()[2]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[2]['eventType']}    ${EventType[7]}
    Should Be Equal As Strings  ${resp.json()[2]['email'][0]}     ${email_1}
    Should Be Equal As Strings  ${resp.json()[2]['sms'][0]['number']}           ${MUSERNAME_L} 
    Should Be Equal As Strings  ${resp.json()[2]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]['number']}       ${MUSERNAME_L} 
    Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[2]['sms'][0]}       ${MUSERNAME_L}
    # Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]}   ${MUSERNAME_L}
    comment   APPOINTMENT-CANCEL
    Should Be Equal As Strings  ${resp.json()[3]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[3]['eventType']}     ${EventType[8]}
    Should Be Equal As Strings  ${resp.json()[3]['email'][0]}      ${email_1}
    Should Be Equal As Strings  ${resp.json()[3]['sms'][0]['number']}           ${MUSERNAME_L} 
    Should Be Equal As Strings  ${resp.json()[3]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]['number']}       ${MUSERNAME_L} 
    Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[3]['sms'][0]}        ${MUSERNAME_L}
    # Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]}    ${MUSERNAME_L}
    comment   DONATION
    Should Be Equal As Strings  ${resp.json()[4]['resourceType']}  ${NotificationResourceType[3]}
    Should Be Equal As Strings  ${resp.json()[4]['eventType']}     ${EventType[10]}
    Should Be Equal As Strings  ${resp.json()[4]['email'][0]}      ${email_1}
    Should Be Equal As Strings  ${resp.json()[4]['sms'][0]['number']}           ${MUSERNAME_L} 
    Should Be Equal As Strings  ${resp.json()[4]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[4]['pushMsg'][0]['number']}       ${MUSERNAME_L} 
    Should Be Equal As Strings  ${resp.json()[4]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[4]['sms'][0]}        ${MUSERNAME_L}
    # Should Be Equal As Strings  ${resp.json()[4]['pushMsg'][0]}    ${MUSERNAME_L}
    comment   LICENSE
    Should Be Equal As Strings  ${resp.json()[5]['resourceType']}  ${NotificationResourceType[2]}
    Should Be Equal As Strings  ${resp.json()[5]['eventType']}     ${EventType[9]}
    Should Be Equal As Strings  ${resp.json()[5]['email'][0]}      ${email_1}
    Should Be Equal As Strings  ${resp.json()[5]['sms'][0]['number']}           ${MUSERNAME_L} 
    Should Be Equal As Strings  ${resp.json()[5]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[5]['pushMsg'][0]['number']}       ${MUSERNAME_L} 
    Should Be Equal As Strings  ${resp.json()[5]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[5]['sms'][0]}        ${MUSERNAME_L}
    # Should Be Equal As Strings  ${resp.json()[5]['pushMsg'][0]}    ${MUSERNAME_L}


JD-TC-Update Email-UH1
    [Documentation]  Update email using consumer login
    ${resp}=  ConsumerLogin  ${CUSERNAME2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${id}  ${resp.json()['id']}
    ${firstname4}=  FakerLibrary.first_name
    ${lastname4}=  FakerLibrary.last_name
    ${resp}=  Update Email   ${id}   ${firstname4}   ${lastname4}  ${e-mail}  
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings   ${resp.json()}   ${LOGIN_NO_ACCESS_FOR_URL}
    
JD-TC-Update Email-UH2
    [Documentation]  Update  email without login
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${resp}=  Update Email   ${pro_id}   ${firstname}   ${lastname}  ${e-mail}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"
     
JD-TC-Update Email-UH3
    [Documentation]  Update email using email  of another provider
    ${domresp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${domresp.status_code}  200
    ${len}=  Get Length  ${domresp.json()}
    ${len}=  Evaluate  ${len}-1
    ${PUSERNAME5}=  Evaluate  ${PUSERNAME}+4070340222
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
    Set Test Variable  ${pro_id5}  ${resp.json()['id']}
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
    ${resp}=  Update Email   ${pro_id5}   ${firstname5}   ${lastname5}  ${email_1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${EMAIL_EXISTS }"


















***comment***

JD-TC-Update Email-5
	[Documentation]  Update email with  branch signup through phonenumber and create user
    ${iscorp_subdomains}=  get_iscorp_subdomains  1
    Log  ${iscorp_subdomains}
    Set Suite Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
    Set Suite Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
    Set Suite Variable  ${sub_domain_id}   ${iscorp_subdomains[0]['subdomainId']}
    ${firstname_C}=  FakerLibrary.first_name
    ${lastname_C}=  FakerLibrary.last_name
    ${MUSERNAME_M}=  Evaluate  ${MUSERNAME}+407017222
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname_C}  ${lastname_C}  ${None}  ${domains}  ${sub_domains}  ${MUSERNAME_M}    ${highest_package[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${MUSERNAME_M}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${MUSERNAME_M}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Encrypted Provider Login  ${MUSERNAME_M}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${pro_id4}  ${resp.json()['id']}
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${MUSERNAME_M}${\n}
    Set Suite Variable  ${MUSERNAME_M}
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${MUSERNAME_M}${\n}
    ${pid4}=  get_acc_id  ${MUSERNAME_M}  
    ${resp}=  Get Account contact information
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['account']}      ${pid4}
    Should Be Equal As Strings  ${resp.json()['primaryPhoneNumber']}  ${MUSERNAME_M}
    Should Be Equal As Strings  ${resp.json()['contactFirstName']}  ${firstname_C}
    Should Be Equal As Strings  ${resp.json()['contactLastName']}  ${lastname_C}
    Should Be Equal As Strings  ${resp.json()['emailVerified']}   ${bool[0]} 
    Should Be Equal As Strings  ${resp.json()['phoneVerified']}   ${bool[1]}

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
    ${PUSERNAME_U1}=  Evaluate  ${PUSERNAME}+3468735
    clear_users  ${PUSERNAME_U1}
    ${firstname2}=  FakerLibrary.name
    ${lastname2}=  FakerLibrary.last_name
    ${dob2}=  FakerLibrary.Date
    ${pin2}=  get_pincode

    ${whpnum}=  Evaluate  ${PUSERNAME_U1}+335241
    ${tlgnum}=  Evaluate  ${PUSERNAME_U1}+335142

    ${resp}=  Create User  ${firstname2}  ${lastname2}  ${dob2}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U1}.${test_mail}   ${userType[0]}  ${pin2}  ${countryCodes[0]}  ${PUSERNAME_U1}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${countryCodes[0]}  ${whpnum}  ${countryCodes[0]}  ${tlgnum}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${u_id}  ${resp.json()}
    ${resp}=  Get User By Id  ${u_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${u_id}  firstName=${firstname2}  lastName=${lastname2}  address=${address2}  mobileNo=${PUSERNAME_U1}  dob=${dob2}  gender=${Genderlist[0]}  userType=${userType[0]}  status=ACTIVE  email=${P_Email}${PUSERNAME_U1}.${test_mail}  city=${location2}  state=${state2}  deptId=${dep_id}  subdomain=${sub_domain_id}

    ${resp}=  Get Account contact information
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['account']}              ${pid4}
    Should Be Equal As Strings  ${resp.json()['primaryPhoneNumber']}  ${MUSERNAME_M}
    Should Be Equal As Strings  ${resp.json()['contactFirstName']}    ${firstname_C}
    Should Be Equal As Strings  ${resp.json()['contactLastName']}     ${lastname_C}
    Should Be Equal As Strings  ${resp.json()['emailVerified']}       ${bool[0]} 
    Should Be Equal As Strings  ${resp.json()['phoneVerified']}       ${bool[1]}

    ${resp}=  Get User
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${p1_id}   ${resp.json()[0]['id']}

    ${resp}=  Get Notification Settings of User  ${p1_id}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    comment   WAITLISTADD
    Should Be Equal As Strings  ${resp.json()[0]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['eventType']}   ${EventType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['email'][0]}    ${P_Email}${PUSERNAME_U1}.${test_mail}
    Should Be Equal As Strings  ${resp.json()[0]['sms'][0]}      ${PUSERNAME_U1}
    Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]}  ${PUSERNAME_U1}
    comment   WAITLIST-CANCEL
    Should Be Equal As Strings  ${resp.json()[1]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[1]['eventType']}     ${EventType[1]}
    Should Be Equal As Strings  ${resp.json()[1]['email'][0]}      ${P_Email}${PUSERNAME_U1}.${test_mail}
    Should Be Equal As Strings  ${resp.json()[1]['sms'][0]}        ${PUSERNAME_U1}
    Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]}    ${PUSERNAME_U1}
    comment   APPOINTMENTADD
    Should Be Equal As Strings  ${resp.json()[2]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[2]['eventType']}    ${EventType[7]}
    Should Be Equal As Strings  ${resp.json()[2]['email'][0]}     ${P_Email}${PUSERNAME_U1}.${test_mail}
    Should Be Equal As Strings  ${resp.json()[2]['sms'][0]}       ${PUSERNAME_U1}
    Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]}   ${PUSERNAME_U1}
    comment   APPOINTMENT-CANCEL
    Should Be Equal As Strings  ${resp.json()[3]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[3]['eventType']}     ${EventType[8]}
    Should Be Equal As Strings  ${resp.json()[3]['email'][0]}      ${P_Email}${PUSERNAME_U1}.${test_mail}
    Should Be Equal As Strings  ${resp.json()[3]['sms'][0]}        ${PUSERNAME_U1}
    Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]}    ${PUSERNAME_U1}
    ${pid5}=  get_acc_id  ${PUSERNAME_U1} 
    ${firstname1}=  FakerLibrary.first_name
    ${lastname1}=  FakerLibrary.last_name
    Set Test Variable  ${email_1}  ${firstname1}${MUSERNAME_M}${C_Email}.${test_mail}
    ${resp}=  Update Email   ${u_id}   ${firstname1}   ${lastname1}   ${email_1}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Notification Settings of User  ${p1_id}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  Get Provider Details    ${pro_id4} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Account contact information
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
