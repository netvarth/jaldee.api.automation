*** Settings ***
Suite Teardown    Delete All Sessions
Force Tags        Provider Signup
Library           Collections
Library           String
Library           json
Library           /ebs/TDD/db.py
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables       /ebs/TDD/varfiles/providers.py
Variables       /ebs/TDD/varfiles/consumerlist.py 
      
*** Test Cases ***

JD-TC-Provider_Signup-1
    [Documentation]    Create a provider with all valid attributes
    ${domresp}=  Get BusinessDomainsConf
    Log  ${domresp.json()}
    Should Be Equal As Strings  ${domresp.status_code}  200
    ${len}=  Get Length  ${domresp.json()}
    ${domain_list}=  Create List
    ${subdomain_list}=  Create List
    FOR  ${domindex}  IN RANGE  ${len}
        Set Test Variable  ${d}  ${domresp.json()[${domindex}]['domain']}    
        Append To List  ${domain_list}    ${d} 
        Set Test Variable  ${sd}  ${domresp.json()[${domindex}]['subDomains'][0]['subDomain']}
        Append To List  ${subdomain_list}    ${sd} 
    END
    Log  ${domain_list}
    Log  ${subdomain_list}
    Set Suite Variable  ${domain_list}
    Set Suite Variable  ${subdomain_list}
    Set Test Variable  ${d1}  ${domain_list[0]}
    Set Test Variable  ${sd1}  ${subdomain_list[0]}
    ${ph}=  Evaluate  ${PUSERNAME}+5666554
    Set Suite Variable  ${ph}
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${d1}  ${sd1}  ${ph}   1
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${ph}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${ph}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Encrypted Provider Login  ${ph}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${ph}${\n}
 
JD-TC-Provider_Signup-2
    [Documentation]    Create a provider with phone number which is not activated but have done signup
    Set Test Variable  ${d2}  ${domain_list[1]}
    Set Test Variable  ${sd2}  ${subdomain_list[1]}
    ${ph1}=  Evaluate  ${PUSERNAME}+5666556
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${d2}  ${sd2}  ${ph1}    2
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${ph1}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${ph1}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Encrypted Provider Login  ${ph1}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${ph1}${\n}

JD-TC-Provider_Signup-3
    [Documentation]    Create a provider with phone number which is not activated and resend OTP to email
    Set Test Variable  ${d3}  ${domain_list[2]}
    Set Suite Variable  ${sd3}  ${subdomain_list[2]}
    ${ph2}=  Evaluate  ${PUSERNAME}+5666557
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${firstname}${P_Email}.${test_mail}  ${d3}  ${sd3}  ${ph2}   3
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${firstname}${P_Email}.${test_mail}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${firstname}${P_Email}.${test_mail}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Encrypted Provider Login  ${ph2}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${ph2}${\n}

JD-TC-Provider_Signup-UH1
    [Documentation]   Create a provider with phone number null
    Set Suite Variable  ${d4}  ${domain_list[3]}
    Set Suite Variable  ${sd4}  ${subdomain_list[3]}
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${d4}  ${sd4}  ${EMPTY}   4
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}    ${PRIMARY_PHONENO_REQUIRED}

JD-TC-Provider_Signup-UH2
    [Documentation]   Create a provider with already existed phone number
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${d4}  ${sd4}  ${ph}   4
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}    ${MOBILE_NO_USED}
   
JD-TC-Provider_Signup-UH3
    [Documentation]   Create a provider with subsector which is not under it's sector
    ${ph3}=  Evaluate  ${PUSERNAME}+66004
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${d4}  ${sd3}  ${ph3}   4
    Should Be Equal As Strings  ${resp.status_code}    422
    Should Be Equal As Strings  "${resp.json()}"  "${INVALID_SUB_SECTOR}"


JD-TC-Provider Signup-UH4
    [Documentation]    Signup a provider with a different country code

    ${PO_Number}    Generate random string    5    0123456789
    ${PO_Number}    Convert To Integer  ${PO_Number}
    ${country_code}    Generate random string    2    0123456789
    ${country_code}    Convert To Integer  ${country_code}
    ${PUSERPH0}=  Evaluate  ${PUSERNAME}+${PO_Number}
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERPH0}${\n}
    Set Suite Variable   ${PUSERPH0}
    ${resp}=   Run Keywords  clear_queue  ${PUSERPH0}   AND  clear_service  ${PUSERPH0}  AND  clear_Item    ${PUSERPH0}  AND   clear_Coupon   ${PUSERPH0}   AND  clear_Discount  ${PUSERPH0}
    ${licid}  ${licname}=  get_highest_license_pkg
    Log  ${licid}
    Log  ${licname}
    Set Suite Variable   ${licid}
    ${domresp}=  Get BusinessDomainsConf
    Log   ${domresp.json()}
    Should Be Equal As Strings  ${domresp.status_code}  200
    ${dlen}=  Get Length  ${domresp.json()}
    ${dom}=  Random Int   min=0  max=${dlen-1}
    Set Suite Variable  ${d1}  ${domresp.json()[${dom}]['domain']}
    ${sdlen}=  Get Length  ${domresp.json()[${dom}]['subDomains']}
    ${sub_dom}=  Random Int   min=0  max=${sdlen-1}
    Set Suite Variable  ${sd1}  ${domresp.json()[${dom}]['subDomains'][${sub_dom}]['subDomain']}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}

    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${firstname}${P_Email}.${test_mail}  ${d1}  ${sd1}  ${PUSERPH0}  ${licid}  countryCode=${countryCode}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    # Should Be Equal As Strings    ${resp.status_code}    422
    # Should Be Equal As Strings  "${resp.json()}"  "${INVALID_COUNTRY_CODE}"

JD-TC-Provider Signup-UH5
    [Documentation]    Signup a consumer with a different country code and provider with same number as consumers

    ${PO_Number}    Generate random string    5    0123456789
    ${PO_Number}    Convert To Integer  ${PO_Number}


    ${CUSERPH3}=  Evaluate  ${CUSERNAME}+${PO_Number}
    # Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${CUSERPH3}${\n}
    ${CUSERPH_SECOND}=  Evaluate  ${CUSERPH3}+1000
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${CUSERPH3_EMAIL}=   Set Variable  ${C_Email}${lastname}${PO_Number}.${test_mail}
    ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${CUSERPH3}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${CUSERPH3_EMAIL}  countryCode=${countryCodes[1]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Activation  ${CUSERPH3_EMAIL}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Set Credential  ${CUSERPH3_EMAIL}  ${PASSWORD}  1  countryCode=${countryCodes[1]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Login  ${CUSERPH3}  ${PASSWORD}  countryCode=${countryCodes[1]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    # ${PUSERPH0}=  Evaluate  ${PUSERNAME}+${PO_Number}
    # Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERPH0}${\n}
    # Set Suite Variable   ${PUSERPH0}
    ${resp}=   Run Keywords  clear_queue  ${CUSERPH3}   AND  clear_service  ${CUSERPH3}  AND  clear_Item    ${CUSERPH3}  AND   clear_Coupon   ${CUSERPH3}   AND  clear_Discount  ${CUSERPH3}
    ${licid}  ${licname}=  get_highest_license_pkg
    Log  ${licid}
    Log  ${licname}
    Set Suite Variable   ${licid}
    ${domresp}=  Get BusinessDomainsConf
    Log   ${domresp.json()}
    Should Be Equal As Strings  ${domresp.status_code}  200
    ${dlen}=  Get Length  ${domresp.json()}
    ${dom}=  Random Int   min=0  max=${dlen-1}
    Set Suite Variable  ${d1}  ${domresp.json()[${dom}]['domain']}
    ${sdlen}=  Get Length  ${domresp.json()[${dom}]['subDomains']}
    ${sub_dom}=  Random Int   min=0  max=${sdlen-1}
    Set Suite Variable  ${sd1}  ${domresp.json()[${dom}]['subDomains'][${sub_dom}]['subDomain']}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${firstname}${P_Email}.${test_mail}  ${d1}  ${sd1}  ${CUSERPH3}  ${licid}  countryCode=${countryCodes[1]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    # Should Be Equal As Strings    ${resp.status_code}    422
    # Should Be Equal As Strings  "${resp.json()}"  "${INVALID_COUNTRY_CODE}"

JD-TC-Provider Signup-4
    [Documentation]    sign up a provider with same number as a user's

    ${resp}=  Encrypted Provider Login  ${PUSERNAME6}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    ${domain}=   Set Variable    ${decrypted_data['sector']}
    ${subdomain}=    Set Variable      ${decrypted_data['subSector']}
    # ${domain}=   Set Variable    ${resp.json()['sector']}
    # ${subdomain}=    Set Variable      ${resp.json()['subSector']}

    ${resp}=   Get Business Profile
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    # Set Test Variable  ${domain_id}  ${resp.json()['serviceSector']['id']}
    # Set Test Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}

    ${iscorp_subdomains}=  get_iscorp_subdomains  1
    Log  ${iscorp_subdomains}
    ${dlen}=  Get Length  ${iscorp_subdomains}
    FOR  ${pos}  IN RANGE  ${dlen}  
        IF  '${iscorp_subdomains[${pos}]['subdomains']}' == '${subdomain}'
            Set Suite Variable  ${sub_domain_id}   ${iscorp_subdomains[${pos}]['subdomainId']}
            Set Suite Variable  ${userSubDomain}  ${iscorp_subdomains[${pos}]['userSubDomain']}
            Exit For Loop
        ELSE
            Continue For Loop
        END
    END

    ${resp}=  View Waitlist Settings
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Run Keyword If  ${resp.json()['filterByDept']}==${bool[0]}   Toggle Department Enable
    Run Keyword If  '${resp}' != '${None}'   Log   ${resp.json()}
    Run Keyword If  '${resp}' != '${None}'   Should Be Equal As Strings  ${resp.status_code}  200

    ${dep_name1}=  FakerLibrary.bs
    ${dep_code1}=   Random Int  min=100   max=999
    ${dep_desc1}=   FakerLibrary.word  
    ${resp}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${dep_id}  ${resp.json()}

    ${PO_Number}    Generate random string    5    123456789
    ${User1}=  Evaluate  ${PUSERNAME}+${PO_Number}
    clear_users  ${User1}
    ${firstname1}=  FakerLibrary.first_name
    ${lastname1}=  FakerLibrary.last_name
    ${dob1}=  FakerLibrary.Date
    # ${pin1}=  get_pincode

    # ${resp}=  Get LocationsByPincode     ${pin1}
    FOR    ${i}    IN RANGE    3
        ${pin1}=  get_pincode
        ${kwstatus}  ${resp} = 	Run Keyword And Ignore Error  Get LocationsByPincode  ${pin1}
        IF    '${kwstatus}' == 'FAIL'
                Continue For Loop
        ELSE IF    '${kwstatus}' == 'PASS'
                Exit For Loop
        END
    END
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${city1}   ${resp.json()[0]['PostOffice'][0]['District']}   
    Set Test Variable  ${state1}  ${resp.json()[0]['PostOffice'][0]['State']}      
    Set Test Variable  ${pin1}    ${resp.json()[0]['PostOffice'][0]['Pincode']}    


    ${whpnum}=  Evaluate  ${PUSERPH0}+356245
    ${tlgnum}=  Evaluate  ${PUSERPH0}+356345

    ${resp}=  Create User  ${firstname1}  ${lastname1}  ${dob1}  ${Genderlist[0]}  ${P_Email}${User1}.${test_mail}   ${userType[0]}  ${pin1}  ${countryCodes[0]}  ${User1}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${countryCodes[0]}  ${whpnum}  ${countryCodes[0]}  ${tlgnum}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${u_id1}  ${resp.json()}

    ${resp}=  Get User By Id  ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${u_id1}  firstName=${firstname1}  lastName=${lastname1}  
    ...   mobileNo=${User1}  dob=${dob1}  gender=${Genderlist[0]}  
    ...   userType=${userType[0]}  status=ACTIVE  email=${P_Email}${User1}.${test_mail}  
    ...   deptId=${dep_id}  subdomain=${userSubDomain}
    # ${NeededString}=    Fetch From Left    ${city1}    (
    # ${Lower_city1} = 	Convert To Lower Case 	${NeededString}
    # ${Lower_city2} = 	Convert To Lower Case 	${resp.json()['city']}
    # Should Be Equal As Strings   ${Lower_city1}  ${Lower_city2}

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Run Keywords  clear_queue  ${User1}   AND  clear_service  ${User1}  AND  clear_Item    ${User1}  AND   clear_Coupon   ${User1}   AND  clear_Discount  ${User1}
    ${licid}  ${licname}=  get_highest_license_pkg
    Log  ${licid}
    Log  ${licname}
    # Set Suite Variable   ${licid}
    # ${domresp}=  Get BusinessDomainsConf
    # Log   ${domresp.json()}
    # Should Be Equal As Strings  ${domresp.status_code}  200
    # ${dlen}=  Get Length  ${domresp.json()}
    # ${dom}=  Random Int   min=0  max=${dlen-1}
    # Set Suite Variable  ${d1}  ${domresp.json()[${dom}]['domain']}
    # ${sdlen}=  Get Length  ${domresp.json()[${dom}]['subDomains']}
    # ${sub_dom}=  Random Int   min=0  max=${sdlen-1}
    # Set Suite Variable  ${sd1}  ${domresp.json()[${dom}]['subDomains'][${sub_dom}]['subDomain']}

    # ${firstname}=  FakerLibrary.first_name
    # ${lastname}=  FakerLibrary.last_name
    # ${address}=  FakerLibrary.address
    # ${dob}=  FakerLibrary.Date
    # ${gender}    Random Element    ${Genderlist}
    ${resp}=  Account SignUp  ${firstname1}  ${lastname1}  ${None}  ${domain}  ${subdomain}  ${User1}  ${licid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings  "${resp.json()}"  "${MOBILE_NO_USED}"
    
    
    # ${resp}=  Account Activation  ${User1}  0
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # Should Be Equal As Strings    ${resp.json()}    "true"
    
    # ${resp}=  Account Set Credential  ${User1}  ${PASSWORD}  0
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=   Encrypted Provider Login  ${User1}  ${PASSWORD}  
    # Log  ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}   200
    
    # ${DAY1}=  db.get_date_by_timezone  ${tz}
    # Set Suite Variable  ${DAY1}  ${DAY1}
    # ${list}=  Create List  1  2  3  4  5  6  7
    # Set Suite Variable  ${list}  ${list}
    # @{Views}=  Create List  self  all  customersOnly
    # ${ph1}=  Evaluate  ${User1}+1000000000
    # ${ph2}=  Evaluate  ${User1}+2000000000
    # ${views}=  Evaluate  random.choice($Views)  random
    # ${name1}=  FakerLibrary.name
    # ${name2}=  FakerLibrary.name
    # ${name3}=  FakerLibrary.name
    # ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
    # ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
    # ${emails1}=  Emails  ${name3}  Email  ${P_Email}${User1}.${test_mail}  ${views}
    # ${bs}=  FakerLibrary.bs
    # ${city}=   get_place
    # ${latti}=  get_latitude
    # ${longi}=  get_longitude
    # ${companySuffix}=  FakerLibrary.companySuffix
    # ${postcode}=  FakerLibrary.postcode
    # # ${address}=  get_address
    # ${parking}   Random Element   ${parkingType}
    # ${24hours}    Random Element    ['True','False']
    # ${desc}=   FakerLibrary.sentence
    # ${url}=   FakerLibrary.url
    # ${sTime}=  add_timezone_time  ${tz}  0  15  
    # Set Suite Variable   ${sTime}
    # ${eTime}=  add_timezone_time  ${tz}  0  45  
    # Set Suite Variable   ${eTime}
    # ${resp}=  Update Business Profile with Schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address1}  ${ph_nos1}  ${ph_nos2}  ${emails1}  ${EMPTY}
    # Log  ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=  Get Business Profile
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${fields}=   Get subDomain level Fields  ${domain}  ${sub_domain_id}
    # Log  ${fields.json()}
    # Should Be Equal As Strings    ${fields.status_code}   200

    # ${virtual_fields}=  get_Subdomainfields  ${fields.json()}

    # ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${sub_domain_id}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Get specializations Sub Domain  ${domain}  ${sub_domain_id}
    # Log  ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}   200

    # ${spec}=  get_Specializations  ${resp.json()}
    # ${resp}=  Update Specialization  ${spec}
    # Log  ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}   200


JD-TC-Provider Signup-5
    [Documentation]    use 1 number to sign up 2 consumers with  differnt country code and a provider

    ${PO_Number}    Generate random string    6    0123456789
    ${PO_Number}    Convert To Integer  ${PO_Number}
    ${country_code1}    Generate random string    2    0123456789
    ${country_code1}    Convert To Integer  ${country_code1}
    ${country_code2}    Generate random string    3    0123456789
    ${country_code2}    Convert To Integer  ${country_code2}

    Comment   with default country code +91
    ${CUSERPH3}=  Evaluate  ${CUSERNAME}+${PO_Number}
    # Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${CUSERPH3}${\n}
    ${CUSERPH_SECOND}=  Evaluate  ${CUSERPH3}+1250
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${CUSERPH3}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${EMPTY}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Activation  ${CUSERPH3}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Set Credential  ${CUSERPH3}  ${PASSWORD}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Login  ${CUSERPH3}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    Comment   with country code   ${country_code1}
    
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${CUSERPH3_EMAIL}=   Set Variable  ${C_Email}${lastname}${country_code1}.${test_mail}
    ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${CUSERPH3}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${CUSERPH3_EMAIL}   countryCode=${countryCodes[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}     422
    Should Be Equal As Strings  "${resp.json()}"  "${MOBILE_NO_USED}"

    # Should Be Equal As Strings    ${resp.status_code}    200
    # ${resp}=  Consumer Activation  ${CUSERPH3_EMAIL}  1
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # ${resp}=  Consumer Set Credential  ${CUSERPH3_EMAIL}  ${PASSWORD}  1   countryCode=+${country_code1}
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # ${resp}=  Consumer Login  ${CUSERPH3}  ${PASSWORD}  countryCode=+${country_code1}
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200

    # Comment   with country code   ${country_code2}

    # ${firstname}=  FakerLibrary.first_name
    # ${lastname}=  FakerLibrary.last_name
    # ${address}=  FakerLibrary.address
    # ${dob}=  FakerLibrary.Date
    # ${gender}    Random Element    ${Genderlist}
    # ${CUSERPH3_EMAIL}=   Set Variable  ${C_Email}${lastname}${country_code2}.${test_mail}
    # ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${CUSERPH3}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${CUSERPH3_EMAIL}   countryCode=${countryCodes[0]}
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # ${resp}=  Consumer Activation  ${CUSERPH3_EMAIL}  1
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # ${resp}=  Consumer Set Credential  ${CUSERPH3_EMAIL}  ${PASSWORD}  1   countryCode=+${country_code2}
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # ${resp}=  Consumer Login  ${CUSERPH3}  ${PASSWORD}  countryCode=+${country_code2}
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # ${resp}=  Consumer Logout
    # Should Be Equal As Strings    ${resp.status_code}    200

    comment  Provider Sign up

    # ${PUSERPH0}=  Evaluate  ${PUSERNAME}+${PO_Number}
    # Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERPH0}${\n}
    # Set Suite Variable   ${PUSERPH0}
    ${resp}=   Run Keywords  clear_queue  ${CUSERPH3}   AND  clear_service  ${CUSERPH3}  AND  clear_Item    ${CUSERPH3}  AND   clear_Coupon   ${CUSERPH3}   AND  clear_Discount  ${CUSERPH3}
    ${licid}  ${licname}=  get_highest_license_pkg
    Log  ${licid}
    Log  ${licname}
    Set Suite Variable   ${licid}
    ${domresp}=  Get BusinessDomainsConf
    Log   ${domresp.json()}
    Should Be Equal As Strings  ${domresp.status_code}  200
    ${dlen}=  Get Length  ${domresp.json()}
    ${dom}=  Random Int   min=0  max=${dlen-1}
    Set Suite Variable  ${d1}  ${domresp.json()[${dom}]['domain']}
    ${sdlen}=  Get Length  ${domresp.json()[${dom}]['subDomains']}
    ${sub_dom}=  Random Int   min=0  max=${sdlen-1}
    Set Suite Variable  ${sd1}  ${domresp.json()[${dom}]['subDomains'][${sub_dom}]['subDomain']}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${d1}  ${sd1}  ${CUSERPH3}  ${licid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Account Activation  ${CUSERPH3}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()}    true
    
    ${resp}=  Account Set Credential  ${CUSERPH3}  ${PASSWORD}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Encrypted Provider Login  ${CUSERPH3}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}  ${list}
    @{Views}=  Create List  self  all  customersOnly
    ${ph1}=  Evaluate  ${CUSERPH3}+1000000000
    ${ph2}=  Evaluate  ${CUSERPH3}+2000000000
    ${views}=  Evaluate  random.choice($Views)  random
    ${name1}=  FakerLibrary.name
    ${name2}=  FakerLibrary.name
    ${name3}=  FakerLibrary.name
    ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
    ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
    ${emails1}=  Emails  ${name3}  Email  ${P_Email}025.${test_mail}  ${views}
    ${bs}=  FakerLibrary.bs
    ${companySuffix}=  FakerLibrary.companySuffix
    # ${city}=   FakerLibrary.state
    # ${latti}=  get_latitude
    # ${longi}=  get_longitude
    # ${postcode}=  FakerLibrary.postcode
    # ${address}=  get_address
    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    Set Suite Variable  ${tz}
    ${parking}   Random Element   ${parkingType}
    ${24hours}    Random Element    ['True','False']
    ${desc}=   FakerLibrary.sentence
    ${url}=   FakerLibrary.url
    ${sTime}=  add_timezone_time  ${tz}  0  15  
    Set Suite Variable   ${sTime}
    ${eTime}=  add_timezone_time  ${tz}  0  45  
    Set Suite Variable   ${eTime}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${resp}=  Update Business Profile with Schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}  ${EMPTY}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${fields}=   Get subDomain level Fields  ${d1}  ${sd1}
    Log  ${fields.json()}
    Should Be Equal As Strings    ${fields.status_code}   200

    ${virtual_fields}=  get_Subdomainfields  ${fields.json()}

    ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${sd1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get specializations Sub Domain  ${d1}  ${sd1}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${spec}=  get_Specializations  ${resp.json()}
    ${resp}=  Update Specialization  ${spec}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200


JD-TC-Provider Signup-UH6
    [Documentation]    signup a branch with international number

    ${PO_Number}    Generate random string    5    0123456789
    ${PO_Number}    Convert To Integer  ${PO_Number}
    ${PUSERPH0}=  Evaluate  ${PUSERNAME}+${PO_Number}
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERPH0}${\n}
    Set Suite Variable   ${PUSERPH0}
    ${resp}=   Run Keywords  clear_queue  ${PUSERPH0}   AND  clear_service  ${PUSERPH0}  AND  clear_Item    ${PUSERPH0}  AND   clear_Coupon   ${PUSERPH0}   AND  clear_Discount  ${PUSERPH0}
    ${licid}  ${licname}=  get_highest_license_pkg
    Log  ${licid}
    Log  ${licname}
    Set Suite Variable   ${licid}
    ${iscorp_subdomains}=  get_iscorp_subdomains  1
    Log  ${iscorp_subdomains}
    Set Test Variable  ${domain}  ${iscorp_subdomains[0]['domain']}
    Set Test Variable  ${d1}  ${iscorp_subdomains[0]['domainId']}
    Set Test Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
    Set Suite Variable  ${sd1}   ${iscorp_subdomains[0]['subdomainId']}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${firstname}${P_Email}.${test_mail}  ${domain}  ${sub_domains}  ${PUSERPH0}  ${licid}  countryCode=${countryCodes[1]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.status_code}  422
    # Should Be Equal As Strings  "${resp.json()}"  "${INVALID_COUNTRY_CODE}"
    
    # ${resp}=  Account Activation  ${PUSERPH0}  0
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # Should Be Equal As Strings    ${resp.json()}    "true"
    
    # ${resp}=  Account Set Credential  ${PUSERPH0}  ${PASSWORD}  0   countryCode=${country_code}
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}  countryCode=${country_code}
    # Log  ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}   200
    
    # ${DAY1}=  db.get_date_by_timezone  ${tz}
    # Set Suite Variable  ${DAY1}  ${DAY1}
    # ${list}=  Create List  1  2  3  4  5  6  7
    # Set Suite Variable  ${list}  ${list}
    # @{Views}=  Create List  self  all  customersOnly
    # ${ph1}=  Evaluate  ${PUSERPH0}+1000000000
    # ${ph2}=  Evaluate  ${PUSERPH0}+2000000000
    # ${views}=  Evaluate  random.choice($Views)  random
    # ${name1}=  FakerLibrary.name
    # ${name2}=  FakerLibrary.name
    # ${name3}=  FakerLibrary.name
    # ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
    # ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
    # ${emails1}=  Emails  ${name3}  Email  ${P_Email}${PUSERPH0}.${test_mail}  ${views}
    # ${bs}=  FakerLibrary.bs
    # ${city}=   get_place
    # ${latti}=  get_latitude
    # ${longi}=  get_longitude
    # ${companySuffix}=  FakerLibrary.companySuffix
    # ${postcode}=  FakerLibrary.postcode
    # ${address}=  get_address
    # ${parking}   Random Element   ${parkingType}
    # ${24hours}    Random Element    ['True','False']
    # ${desc}=   FakerLibrary.sentence
    # ${url}=   FakerLibrary.url
    # ${sTime}=  add_timezone_time  ${tz}  0  15  
    # Set Suite Variable   ${sTime}
    # ${eTime}=  add_timezone_time  ${tz}  0  45  
    # Set Suite Variable   ${eTime}
    # ${resp}=  Update Business Profile with Schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}  ${EMPTY}
    # Log  ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=  Get Business Profile
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${fields}=   Get subDomain level Fields  ${d1}  ${sd1}
    # Log  ${fields.json()}
    # Should Be Equal As Strings    ${fields.status_code}   200

    # ${virtual_fields}=  get_Subdomainfields  ${fields.json()}

    # ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${sd1}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Get specializations Sub Domain  ${d1}  ${sd1}
    # Should Be Equal As Strings    ${resp.status_code}   200

    # ${spec}=  get_Specializations  ${resp.json()}
    # ${resp}=  Update Specialization  ${spec}
    # Log  ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}   200


JD-TC-Provider Signup-UH7
    [Documentation]    signup a provider without country code

    ${PO_Number}    Generate random string    5    0123456789
    ${PO_Number}    Convert To Integer  ${PO_Number}
    ${country_code}    Generate random string    2    0123456789
    ${country_code}    Convert To Integer  ${country_code}
    ${PUSERPH0}=  Evaluate  ${PUSERNAME}+${PO_Number}
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERPH0}${\n}
    Set Suite Variable   ${PUSERPH0}
    ${resp}=   Run Keywords  clear_queue  ${PUSERPH0}   AND  clear_service  ${PUSERPH0}  AND  clear_Item    ${PUSERPH0}  AND   clear_Coupon   ${PUSERPH0}   AND  clear_Discount  ${PUSERPH0}
    ${licid}  ${licname}=  get_highest_license_pkg
    Log  ${licid}
    Log  ${licname}
    Set Suite Variable   ${licid}
    ${domresp}=  Get BusinessDomainsConf
    Log   ${domresp.json()}
    Should Be Equal As Strings  ${domresp.status_code}  200
    ${dlen}=  Get Length  ${domresp.json()}
    ${dom}=  Random Int   min=0  max=${dlen-1}
    Set Suite Variable  ${d1}  ${domresp.json()[${dom}]['domain']}
    ${sdlen}=  Get Length  ${domresp.json()[${dom}]['subDomains']}
    ${sub_dom}=  Random Int   min=0  max=${sdlen-1}
    Set Suite Variable  ${sd1}  ${domresp.json()[${dom}]['subDomains'][${sub_dom}]['subDomain']}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${firstname}${P_Email}.${test_mail}  ${d1}  ${sd1}  ${PUSERPH0}  ${licid}  countryCode=${EMPTY}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${COUNTRY_CODEREQUIRED}"


JD-TC-Provider Signup-UH8
    [Documentation]    signup a provider with same number and country code as that of another provider's customer.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME37}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
    IF  ${resp.json()['walkinConsumerBecomesJdCons']}==${bool[0]}
        ${resp}=  Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${EMPTY}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}

    ${PO_Number}    Generate random string    5    0123456789
    ${PO_Number}    Convert To Integer  ${PO_Number}
    ${CUSERPH0}=  Evaluate  ${PUSERNAME37}+${PO_Number}
    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${resp}=  AddCustomer  ${CUSERPH0}  firstName=${firstname}   lastName=${lastname}  countryCode=${countryCodes[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}
    
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERPH0}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['id']}  ${cid}

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Run Keywords  clear_queue  ${CUSERPH0}   AND  clear_service  ${CUSERPH0}  
    ...   AND  clear_Item    ${CUSERPH0}  AND   clear_Coupon   ${CUSERPH0}   
    ...   AND  clear_Discount  ${CUSERPH0}   AND  clear_customer  ${CUSERPH0}

    ${licid}  ${licname}=  get_highest_license_pkg
    Log  ${licid}
    Log  ${licname}
    Set Suite Variable   ${licid}
    ${domresp}=  Get BusinessDomainsConf
    Log   ${domresp.json()}
    Should Be Equal As Strings  ${domresp.status_code}  200
    ${dlen}=  Get Length  ${domresp.json()}
    ${dom}=  Random Int   min=0  max=${dlen-1}
    Set Suite Variable  ${d1}  ${domresp.json()[${dom}]['domain']}
    ${sdlen}=  Get Length  ${domresp.json()[${dom}]['subDomains']}
    ${sub_dom}=  Random Int   min=0  max=${sdlen-1}
    Set Suite Variable  ${sd1}  ${domresp.json()[${dom}]['subDomains'][${sub_dom}]['subDomain']}

    
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${firstname}${P_Email}.${test_mail}  ${d1}  ${sd1}  ${CUSERPH0}  ${licid}  countryCode=${countryCodes[1]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.status_code}  422
    # Should Be Equal As Strings  "${resp.json()}"  "${INVALID_COUNTRY_CODE}"
    

JD-TC-Provider Signup-7
    [Documentation]    signup a provider with same number as another provider and different country code.
    
    ${licid}  ${licname}=  get_highest_license_pkg
    Log  ${licid}
    Log  ${licname}
    Set Suite Variable   ${licid}
    ${domresp}=  Get BusinessDomainsConf
    Log   ${domresp.json()}
    Should Be Equal As Strings  ${domresp.status_code}  200
    ${dlen}=  Get Length  ${domresp.json()}
    ${dom}=  Random Int   min=0  max=${dlen-1}
    Set Suite Variable  ${d1}  ${domresp.json()[${dom}]['domain']}
    ${sdlen}=  Get Length  ${domresp.json()[${dom}]['subDomains']}
    ${sub_dom}=  Random Int   min=0  max=${sdlen-1}
    Set Suite Variable  ${sd1}  ${domresp.json()[${dom}]['subDomains'][${sub_dom}]['subDomain']}

    ${country_code}    Generate random string    3    0123456789
    ${country_code}    Convert To Integer  ${country_code}
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${firstname}${P_Email}.${test_mail}  ${d1}  ${sd1}  ${PUSERNAME37}  ${licid}  countryCode=${country_code}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    
JD-TC-Provider_Signup-6

    [Documentation]    Get default consumer notification settings after provider signup.

    ${domresp}=  Get BusinessDomainsConf
    Log  ${domresp.json()}
    Should Be Equal As Strings  ${domresp.status_code}  200
    ${len}=  Get Length  ${domresp.json()}
    ${domain_list}=  Create List
    ${subdomain_list}=  Create List
    FOR  ${domindex}  IN RANGE  ${len}
        Set Test Variable  ${d}  ${domresp.json()[${domindex}]['domain']}    
        Append To List  ${domain_list}    ${d} 
        Set Test Variable  ${sd}  ${domresp.json()[${domindex}]['subDomains'][0]['subDomain']}
        Append To List  ${subdomain_list}    ${sd} 
    END
    Log  ${domain_list}
    Log  ${subdomain_list}
    Set Suite Variable  ${domain_list}
    Set Suite Variable  ${subdomain_list}
    Set Test Variable  ${d1}  ${domain_list[0]}
    Set Test Variable  ${sd1}  ${subdomain_list[0]}
    ${ph}=  Evaluate  ${PUSERNAME}+7853558
    Set Suite Variable  ${ph}
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${d1}  ${sd1}  ${ph}   1
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${ph}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${ph}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Encrypted Provider Login  ${ph}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${ph}${\n}
    
    ${resp}=  Get Consumer Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    Should Be Equal As Strings  ${resp.json()[0]['resourceType']}      ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['eventType']}         ${EventType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['email']}             ${bool[1]}
    Should Be Equal As Strings  ${resp.json()[0]['sms']}               ${bool[1]}
    Should Be Equal As Strings  ${resp.json()[0]['pushNotification']}  ${bool[1]}
   
    Should Be Equal As Strings  ${resp.json()[1]['resourceType']}      ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[1]['eventType']}         ${EventType[1]}
    Should Be Equal As Strings  ${resp.json()[1]['email']}             ${bool[1]}
    Should Be Equal As Strings  ${resp.json()[1]['sms']}               ${bool[1]}
    Should Be Equal As Strings  ${resp.json()[1]['pushNotification']}  ${bool[1]}

    Should Be Equal As Strings  ${resp.json()[2]['resourceType']}      ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[2]['eventType']}         ${EventType[4]}
    Should Be Equal As Strings  ${resp.json()[2]['email']}             ${bool[0]}
    Should Be Equal As Strings  ${resp.json()[2]['sms']}               ${bool[0]}
    Should Be Equal As Strings  ${resp.json()[2]['pushNotification']}  ${bool[0]}

    Should Be Equal As Strings  ${resp.json()[3]['resourceType']}      ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[3]['eventType']}         ${EventType[5]}
    Should Be Equal As Strings  ${resp.json()[3]['email']}             ${bool[0]}
    Should Be Equal As Strings  ${resp.json()[3]['sms']}               ${bool[0]}
    Should Be Equal As Strings  ${resp.json()[3]['pushNotification']}  ${bool[0]}

    Should Be Equal As Strings  ${resp.json()[4]['resourceType']}      ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[4]['eventType']}         ${EventType[6]}
    Should Be Equal As Strings  ${resp.json()[4]['email']}             ${bool[0]}
    Should Be Equal As Strings  ${resp.json()[4]['sms']}               ${bool[0]}
    Should Be Equal As Strings  ${resp.json()[4]['pushNotification']}  ${bool[0]}

    Should Be Equal As Strings  ${resp.json()[5]['resourceType']}      ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[5]['eventType']}         ${EventType[4]}
    Should Be Equal As Strings  ${resp.json()[5]['email']}             ${bool[0]}
    Should Be Equal As Strings  ${resp.json()[5]['sms']}               ${bool[0]}
    Should Be Equal As Strings  ${resp.json()[5]['pushNotification']}  ${bool[0]}

    Should Be Equal As Strings  ${resp.json()[6]['resourceType']}      ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[6]['eventType']}         ${EventType[6]}
    Should Be Equal As Strings  ${resp.json()[6]['email']}             ${bool[0]}
    Should Be Equal As Strings  ${resp.json()[6]['sms']}               ${bool[0]}
    Should Be Equal As Strings  ${resp.json()[6]['pushNotification']}  ${bool[0]}

    Should Be Equal As Strings  ${resp.json()[7]['resourceType']}      ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[7]['eventType']}         ${EventType[7]}
    Should Be Equal As Strings  ${resp.json()[7]['email']}             ${bool[1]}
    Should Be Equal As Strings  ${resp.json()[7]['sms']}               ${bool[1]}
    Should Be Equal As Strings  ${resp.json()[7]['pushNotification']}  ${bool[1]}

    Should Be Equal As Strings  ${resp.json()[8]['resourceType']}      ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[8]['eventType']}         ${EventType[8]}
    Should Be Equal As Strings  ${resp.json()[8]['email']}             ${bool[1]}
    Should Be Equal As Strings  ${resp.json()[8]['sms']}               ${bool[1]}
    Should Be Equal As Strings  ${resp.json()[8]['pushNotification']}  ${bool[0]}

    Should Be Equal As Strings  ${resp.json()[9]['resourceType']}      ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[9]['eventType']}         ${EventType[11]}
    Should Be Equal As Strings  ${resp.json()[9]['email']}             ${bool[1]}
    Should Be Equal As Strings  ${resp.json()[9]['sms']}               ${bool[1]}
    Should Be Equal As Strings  ${resp.json()[9]['pushNotification']}  ${bool[0]}

    Should Be Equal As Strings  ${resp.json()[10]['resourceType']}      ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[10]['eventType']}         ${EventType[12]}
    Should Be Equal As Strings  ${resp.json()[10]['email']}             ${bool[1]}
    Should Be Equal As Strings  ${resp.json()[10]['sms']}               ${bool[1]}
    Should Be Equal As Strings  ${resp.json()[10]['pushNotification']}  ${bool[0]}    

    Should Be Equal As Strings  ${resp.json()[11]['resourceType']}      ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[11]['eventType']}         ${EventType[13]}
    Should Be Equal As Strings  ${resp.json()[11]['email']}             ${bool[1]}
    Should Be Equal As Strings  ${resp.json()[11]['sms']}               ${bool[1]}
    Should Be Equal As Strings  ${resp.json()[11]['pushNotification']}  ${bool[0]}

    Should Be Equal As Strings  ${resp.json()[12]['resourceType']}      ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[12]['eventType']}         ${EventType[14]}
    Should Be Equal As Strings  ${resp.json()[12]['email']}             ${bool[1]}
    Should Be Equal As Strings  ${resp.json()[12]['sms']}               ${bool[1]}
    Should Be Equal As Strings  ${resp.json()[12]['pushNotification']}  ${bool[0]}

    Should Be Equal As Strings  ${resp.json()[13]['resourceType']}      ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[13]['eventType']}         ${EventType[15]}
    Should Be Equal As Strings  ${resp.json()[13]['email']}             ${bool[1]}
    Should Be Equal As Strings  ${resp.json()[13]['sms']}               ${bool[1]}
    Should Be Equal As Strings  ${resp.json()[13]['pushNotification']}  ${bool[1]}

    Should Be Equal As Strings  ${resp.json()[14]['resourceType']}      ${NotificationResourceType[4]}
    Should Be Equal As Strings  ${resp.json()[14]['eventType']}         ${EventType[16]}
    Should Be Equal As Strings  ${resp.json()[14]['email']}             ${bool[1]}
    Should Be Equal As Strings  ${resp.json()[14]['sms']}               ${bool[1]}
    Should Be Equal As Strings  ${resp.json()[14]['pushNotification']}  ${bool[1]}

    Should Be Equal As Strings  ${resp.json()[15]['resourceType']}      ${NotificationResourceType[4]}
    Should Be Equal As Strings  ${resp.json()[15]['eventType']}         ${EventType[17]}
    Should Be Equal As Strings  ${resp.json()[15]['email']}             ${bool[1]}
    Should Be Equal As Strings  ${resp.json()[15]['sms']}               ${bool[1]}
    Should Be Equal As Strings  ${resp.json()[15]['pushNotification']}  ${bool[1]}

    Should Be Equal As Strings  ${resp.json()[16]['resourceType']}      ${NotificationResourceType[4]}
    Should Be Equal As Strings  ${resp.json()[16]['eventType']}         ${EventType[18]}
    Should Be Equal As Strings  ${resp.json()[16]['email']}             ${bool[1]}
    Should Be Equal As Strings  ${resp.json()[16]['sms']}               ${bool[1]}
    Should Be Equal As Strings  ${resp.json()[16]['pushNotification']}  ${bool[1]}





   
