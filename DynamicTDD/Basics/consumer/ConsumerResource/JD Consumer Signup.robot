*** Settings ***

Suite Teardown    Delete All Sessions
Test Teardown    Delete All Sessions
Force Tags        ConsumerSignup
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/consumermail.py
Variables         /ebs/TDD/varfiles/musers.py


*** Variables ***

@{Views}  self  all  customersOnly
${CUSERPH}      ${CUSERNAME}

***Keywords***

Get branch by license
    [Arguments]   ${lic_id}
    
    ${resp}=   Get File    ${EXECDIR}/TDD/varfiles/musers.py
    ${len}=   Split to lines  ${resp}
    ${length}=  Get Length   ${len}
     
    FOR   ${a}  IN RANGE  ${length}
            
        ${Branch_PH}=  Set Variable  ${MUSERNAME${a}}
        ${resp}=  Encrypted Provider Login  ${MUSERNAME${a}}  ${PASSWORD}
        Should Be Equal As Strings    ${resp.status_code}    200

        ${decrypted_data}=  db.decrypt_data  ${resp.content}
        Log  ${decrypted_data}
        ${domain}=   Set Variable    ${decrypted_data['sector']}
        ${subdomain}=    Set Variable      ${decrypted_data['subSector']}

        ${resp}=   Get Active License
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}   200
        ${pkg_id}=   Set Variable  ${resp.json()['accountLicense']['licPkgOrAddonId']}
        ${pkg_name}=   Set Variable  ${resp.json()['accountLicense']['name']}
	    # Run Keyword IF   ${resp.json()['accountLicense']['licPkgOrAddonId']} == ${lic_id}   AND   ${resp.json()['accountLicense']['name']} == ${lic_name}   Exit For Loop
        Exit For Loop IF  ${resp.json()['accountLicense']['licPkgOrAddonId']} == ${lic_id}

    END
    [Return]  ${Branch_PH}


*** Test Cases ***                                                                     

JD-TC-Consumer Signup-1
    [Documentation]   Create consumer with all valid attributes except email
    ${CUSERPH0}=  Evaluate  ${CUSERPH}+100100201
    Set Suite Variable   ${CUSERPH0}
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${CUSERPH0}${\n}
    ${CUSERPH_SECOND}=  Evaluate  ${CUSERPH0}+1000
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${CUSERPH0}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${EMPTY}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Activation  ${CUSERPH0}  ${OtpPurpose['ConsumerSignUp']}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Set Credential  ${CUSERPH0}  ${PASSWORD}  ${OtpPurpose['ConsumerSignUp']}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Login  ${CUSERPH0}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    Append To File  ${EXECDIR}/TDD/consumernumbers.txt  ${CUSERPH0}${\n}

JD-TC-Consumer Signup-2
    [Documentation]    Create another consumer with phone number which is not activated but have done signup
    ${CUSERPH1}=  Evaluate  ${CUSERPH}+100100202
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${CUSERPH1}${\n}
    Set Suite Variable   ${CUSERPH1}
    ${CUSERPH_SECOND}=  Evaluate  ${CUSERPH1}+1000
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${CUSERPH1}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${EMPTY}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${CUSERPH_SECOND}=  Evaluate  ${CUSERPH_SECOND}+1
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${CUSERPH1}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${EMPTY}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Activation  ${CUSERPH1}  ${OtpPurpose['ConsumerSignUp']}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Set Credential  ${CUSERPH1}  ${PASSWORD}  ${OtpPurpose['ConsumerSignUp']}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERPH1}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    Append To File  ${EXECDIR}/TDD/consumernumbers.txt  ${CUSERPH1}${\n}

JD-TC-Consumer Signup-3
    [Documentation]   Create consumer with email
    ${CUSERPH2}=  Evaluate  ${CUSERPH}+100100203
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${CUSERPH2}${\n}
    Set Suite Variable   ${CUSERPH2}
    ${CUSERPH3}=  Evaluate  ${CUSERPH}+100100204
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${CUSERPH3}${\n}
    Set Suite Variable   ${CUSERPH3}
    ${CUSERPH_SECOND}=  Evaluate  ${CUSERPH2}+1000
    ${CUSERMAIL2}=   Set Variable  ${C_Email}ph203.ynwtest@netvarth.com
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${CUSERPH2}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${CUSERMAIL2}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Activation  ${CUSERMAIL2}  ${OtpPurpose['ConsumerSignUp']}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Set Credential  ${CUSERMAIL2}  ${PASSWORD}  ${OtpPurpose['ConsumerSignUp']}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Login  ${CUSERPH2}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    Append To File  ${EXECDIR}/TDD/consumernumbers.txt  ${CUSERPH2}${\n}

JD-TC-Consumer Signup-4
    [Documentation]   Create a Consumer with existing provider's phone number
    ${CUSERPH_SECOND}=  Evaluate  ${CUSERPH3}+1000
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${PUSERNAME5}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${EMPTY}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    Append To File  ${EXECDIR}/TDD/consumernumbers.txt  ${PUSERNAME5}${\n}


# JD-TC-Consumer Signup-5
#     [Documentation]   Signup an existing consumer to a provider
#     ${domresp}=  Get BusinessDomainsConf
#     Log   ${domresp.json()}
#     Should Be Equal As Strings  ${domresp.status_code}  200
#     ${dlen}=  Get Length  ${domresp.json()}
#     FOR  ${pos}  IN RANGE  ${dlen}
#         ${sublen}=  Get Length  ${domresp.json()[${pos}]['subDomains']}
#         Set Test Variable  ${dpos}   ${pos}
#         Set Suite Variable  ${d1}  ${domresp.json()[${pos}]['domain']}
#     END

#     FOR  ${pos}  IN RANGE  ${sublen}
#         Set Suite Variable  ${sd1}  ${domresp.json()[${dpos}]['subDomains'][${pos}]['subDomain']}
#     END

#     ${licresp}=   Get Licensable Packages
#     Should Be Equal As Strings   ${licresp.status_code}   200
#     ${liclen}=  Get Length  ${licresp.json()}
#     FOR  ${pos}  IN RANGE  ${liclen}
#         Set Suite Variable  ${pkgId}  ${licresp.json()[${pos}]['pkgId']}
#         Set Suite Variable  ${pkg_name}  ${licresp.json()[${pos}]['displayName']}
#     END
#     ${CUSERPH_SECOND}=  Evaluate  ${CUSERPH0}+1000
#     ${firstname}=  FakerLibrary.first_name
#     ${lastname}=  FakerLibrary.last_name
#     ${address}=  FakerLibrary.address
#     ${dob}=  FakerLibrary.Date
#     ${gender}    Random Element    ${Genderlist}

#     ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${d1}  ${sd1}  ${CUSERPH0}    ${pkgId}
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${resp}=  Account Activation  ${CUSERPH0}  0
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     Should Be Equal As Strings  "${resp.json()}"    "upgraded"
#     ${resp}=  Account Set Credential  ${CUSERPH0}  ${PASSWORD}  0
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${resp}=  Encrypted Provider Login  ${CUSERPH0}  ${PASSWORD}
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200

    
#     ${CUSERPH3}=  Evaluate  ${CUSERPH}+100100204
#     Append To File  ${EXECDIR}/TDD/numbers.txt  ${CUSERPH3}${\n}
#     Set Suite Variable   ${CUSERPH3}
#     ${CUSERPH4}=  Evaluate  ${CUSERPH}+100100205
#     Append To File  ${EXECDIR}/TDD/numbers.txt  ${CUSERPH4}${\n}
#     Set Suite Variable   ${CUSERPH4}
#     ${CUSERMAIL0}=   Set Variable  ${C_Email}ph201.ynwtest@netvarth.com
#     ${views}=  Evaluate  random.choice($Views)  random
#     ${name1}=  FakerLibrary.name
#     ${name2}=  FakerLibrary.name
#     ${name3}=  FakerLibrary.name
#     ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${CUSERPH3}  ${views}
#     ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${CUSERPH4}  ${views}
#     ${emails1}=  Emails  ${name3}  Email  ${CUSERMAIL0}  ${views}
#     ${bs}=  FakerLibrary.bs
#     Set Suite Variable   ${bs}
#     ${city}=   get_place
#     Set Suite Variable   ${city}
#     ${latti}=  get_latitude
#     Set Suite Variable   ${latti}
#     ${longi}=  get_longitude
#     Set Suite Variable   ${longi}
#     ${companySuffix}=  FakerLibrary.companySuffix
#     Set Suite Variable   ${companySuffix}
#     ${postcode}=  FakerLibrary.postcode
#     ${address}=  get_address
#     ${DAY1}=  db.get_date_by_timezone  ${tz}
#     Set Suite Variable  ${DAY1}  ${DAY1}
#     ${list}=  Create List  1  2  3  4  5  6  7
#     Set Suite Variable  ${list}  ${list}
#     ${sTime}=  add_timezone_time  ${tz}  0  15  
#     ${eTime}=  add_timezone_time  ${tz}  0  30   
#     ${desc}=   FakerLibrary.sentence
#     Set Suite Variable    ${desc}
#     ${url}=   FakerLibrary.url
#     Set Suite Variable  ${url}
#     ${parking}   Random Element   ${parkingType}
#     Set Suite Variable  ${parking}
#     ${24hours}    Random Element    ['True','False']
#     Set Suite Variable  ${24hours}
#     ${resp}=  Create Business Profile  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${bool[1]}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${resp}=  Get Business Profile
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
    
#     ${resp}=  ProviderLogout
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${resp}=  Consumer Login  ${CUSERPH0}  ${PASSWORD}
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     Should Contain    ${resp.json()}  "userName"

JD-TC-Consumer Signup-UH1
    [Documentation]   Create a Consumer with empty phone number 
    ${CUSERPH_SECOND}=  Evaluate  ${CUSERPH3}+1000
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${EMPTY}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${EMPTY}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings  "${resp.json()}"    "${PRIMARY_PHONENO_REQUIRED}"

JD-TC-Consumer Signup-UH2
    [Documentation]   Create a Consumer with existing consumer's phone number
    ${CUSERPH_SECOND}=  Evaluate  ${CUSERPH2}+1000
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${CUSERPH2}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${EMPTY}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  "${resp.json()}"     "${MOBILE_NO_USED}"


JD-TC-Consumer Signup-5
    [Documentation]   Create consumer with different country code

    ${resp}=   Get File    /ebs/TDD/consumernumbers.txt
    ${numbers}=   Split to lines  ${resp}
    Set Suite Variable  ${numbers}
    ${length}=  Get Length   ${numbers}

    FOR   ${i}  IN RANGE   5
        ${PO_Number}=  random_phone_num_generator
        Log  ${PO_Number}
        ${country_code}=  Set Variable  ${PO_Number.country_code}
        ${CUSERPH3}=  Set Variable  ${PO_Number.national_number}
        ${keywordstatus} 	${value} = 	Run Keyword And Ignore Error   List Should Not Contain Value  ${numbers}  ${CUSERPH3}
        Log Many  ${keywordstatus} 	${value}
        Continue For Loop If  '${keywordstatus}' == 'FAIL'
        Run Keyword If  '${keywordstatus}' == 'PASS'  Append To List   ${numbers}  ${CUSERPH3}
        Exit For Loop IF   '${keywordstatus}' == 'PASS'
    END

    # FOR  ${i}  IN RANGE   3
    #     ${country_code}    Generate random string    2    0123456789
    #     Exit For Loop If  "${country_code}" != "91"
    # END
    # ${country_code}    Generate random string    2    0123456789
    # ${country_code}    Convert To Integer  ${country_code}
    # Append To File  ${EXECDIR}/TDD/numbers.txt  ${CUSERPH3}${\n}
    ${CUSERPH_SECOND}=  Evaluate  ${CUSERPH3}+1000
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${CUSERPH3_EMAIL}=   Set Variable  ${C_Email}${lastname}${CUSERPH3}.ynwtest@netvarth.com
    ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${CUSERPH3}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${CUSERPH3_EMAIL}  countryCode=+${country_code}
    Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    422
    # Should Be Equal As Strings  ${resp.json()}    ${INVALID_PHONE}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Activation  ${CUSERPH3_EMAIL}  ${OtpPurpose['ConsumerSignUp']}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Set Credential  ${CUSERPH3_EMAIL}  ${PASSWORD}  ${OtpPurpose['ConsumerSignUp']}  countryCode=+${countryCode}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Login  ${CUSERPH3}  ${PASSWORD}  countryCode=+${countryCode}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    Append To File  ${EXECDIR}/TDD/consumernumbers.txt  ${CUSERPH3}${\n}


JD-TC-Consumer Signup-6
    [Documentation]   Create consumer with same phone number but different country code

    FOR   ${i}  IN RANGE   5
        # ${PO_Number1}    Generate random string    8    0123456789
        # ${PO_Number1}    Convert To Integer  ${PO_Number1}
        # ${CUSERPH4}=  Evaluate  ${CUSERPH}+${PO_Number1}
        # ${PO_Number1}=  random_phone_num_generator
        ${PO_Number1}=  Get Random Valid Phone Number
        Log  ${PO_Number1}
        ${country_code1}=  Set Variable  ${PO_Number1.country_code}
        ${CUSERPH4}=  Set Variable  ${PO_Number1.national_number}
        ${keywordstatus} 	${value} = 	Run Keyword And Ignore Error   List Should Not Contain Value  ${numbers}  ${CUSERPH4}
        Log Many  ${keywordstatus} 	${value}
        Continue For Loop If  '${keywordstatus}' == 'FAIL'
        Run Keyword If  '${keywordstatus}' == 'PASS'  Append To List   ${numbers}  ${CUSERPH4}
        Exit For Loop IF   '${keywordstatus}' == 'PASS'
    END

    # FOR  ${i}  IN RANGE   3
    #     ${country_code1}    Generate random string    2    0123456789
    #     Exit For Loop If  "${country_code1}" != "91"
    # END

    # ${PO_Number1}    Generate random string    8    0123456789
    # ${PO_Number1}    Convert To Integer  ${PO_Number1}
    # ${PO_Number2}    Generate random string    4    0123456789
    # ${PO_Number3}    Generate random string    4    0123456789
    # ${country_code1}    Generate random string    2    0123456789
    # ${country_code1}    Convert To Integer  ${country_code1}
    # ${country_code2}    Generate random string    3    0123456789
    # ${country_code2}    Convert To Integer  ${country_code2}
    ${other_country_codes}=   random_country_codes  ${CUSERPH4}
    Log  ${other_country_codes}
    Log List  ${other_country_codes}
    Append To List  ${other_country_codes}  ${country_code1}
    ${unique_ccodes}=    Remove Duplicates    ${other_country_codes}
    Remove Values From List  ${unique_ccodes}  ${country_code1}
    ${country_code2}=  Evaluate  random.choice($unique_ccodes)  random
    Remove Values From List  ${unique_ccodes}  ${country_code2}


    Comment   with default country code +91
    # ${CUSERPH4}=  Evaluate  ${CUSERPH}+${PO_Number1}
    # Append To File  ${EXECDIR}/TDD/numbers.txt  ${CUSERPH4}${\n}
    ${CUSERPH_SECOND}=  Evaluate  ${CUSERPH4}+1000
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${CUSERPH4}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${EMPTY}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Activation  ${CUSERPH4}  ${OtpPurpose['ConsumerSignUp']}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Set Credential  ${CUSERPH4}  ${PASSWORD}  ${OtpPurpose['ConsumerSignUp']}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Login  ${CUSERPH4}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    Append To File  ${EXECDIR}/TDD/consumernumbers.txt  ${CUSERPH4}${\n}

    Comment   with country code   ${country_code1}
    
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${CUSERPH4_EMAIL1}=   Set Variable  ${C_Email}${lastname}${country_code1}.ynwtest@netvarth.com
    ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${CUSERPH4}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${CUSERPH4_EMAIL1}   countryCode=+${country_code1}
    Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    422
    # Should Be Equal As Strings  ${resp.json()}    ${INVALID_PHONE}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Activation  ${CUSERPH4_EMAIL1}  ${OtpPurpose['ConsumerSignUp']}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Set Credential  ${CUSERPH4_EMAIL1}  ${PASSWORD}  ${OtpPurpose['ConsumerSignUp']}   countryCode=+${country_code1}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Login  ${CUSERPH4}  ${PASSWORD}  countryCode=+${country_code1}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    Comment   with country code   ${country_code2}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${CUSERPH4_EMAIL2}=   Set Variable  ${C_Email}${lastname}${country_code2}.ynwtest@netvarth.com
    ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${CUSERPH4}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${CUSERPH4_EMAIL2}   countryCode=+${country_code2}
    Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    422
    # Should Be Equal As Strings  ${resp.json()}    ${INVALID_PHONE}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Activation  ${CUSERPH4_EMAIL2}  1
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Set Credential  ${CUSERPH4_EMAIL2}  ${PASSWORD}  1   countryCode=+${country_code2}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Login  ${CUSERPH4}  ${PASSWORD}  countryCode=+${country_code2}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-Consumer Signup-7
    [Documentation]   sign up a provider consumer as consumer with walkinConsumerBecomesJdCons as false.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME8}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${bname}  ${resp.json()['businessName']}
    # Set Test Variable  ${pid}  ${resp.json()['id']}
    # Set Test Variable  ${uniqueId}  ${resp.json()['uniqueId']}

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
    ${resp1}=   Run Keyword If  ${resp.json()['walkinConsumerBecomesJdCons']}==${bool[1]}   Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[0]}  ${EMPTY}
    Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.json()}
    Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[0]}

    FOR   ${i}  IN RANGE   5
        ${PO_Number1}    Generate random string    3    0123456789
        ${PO_Number1}    Convert To Integer  ${PO_Number1}
        ${CUSERPH0}=  Evaluate  ${CUSERNAME}+${PO_Number1}
        ${keywordstatus} 	${value} = 	Run Keyword And Ignore Error   List Should Not Contain Value  ${numbers}  ${CUSERPH0}
        Log Many  ${keywordstatus} 	${value}
        Continue For Loop If  '${keywordstatus}' == 'FAIL'
        Run Keyword If  '${keywordstatus}' == 'PASS'  Append To List   ${numbers}  ${CUSERPH0}
        Exit For Loop IF   '${keywordstatus}' == 'PASS'
    END
    
    # ${PO_Number1}    Generate random string    3    0123456789
    # ${PO_Number1}    Convert To Integer  ${PO_Number1}
    # ${CUSERPH0}=  Evaluate  ${CUSERNAME}+${PO_Number1}
    ${fname}=  FakerLibrary.first_name
    ${lname}=  FakerLibrary.last_name
    ${resp}=  AddCustomer  ${CUSERPH0}  firstName=${fname}  lastName=${lname}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}
    
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERPH0}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['id']}  ${cid}

    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${CUSERPH_SECOND}=  Evaluate  ${CUSERPH0}+1000
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}=  Random Element    ${Genderlist}
    ${resp}=  Consumer SignUp  ${fname}  ${lname}  ${address}  ${CUSERPH0}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${EMPTY} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Activation  ${CUSERPH0}  ${OtpPurpose['ConsumerSignUp']}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Set Credential  ${CUSERPH0}  ${PASSWORD}  ${OtpPurpose['ConsumerSignUp']}  
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERPH0}  ${PASSWORD}  
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    Append To File  ${EXECDIR}/TDD/consumernumbers.txt  ${CUSERPH0}${\n}


JD-TC-Consumer Signup-8
    [Documentation]   sign up a provider consumer with different country code

    ${resp}=  Encrypted Provider Login  ${PUSERNAME8}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${bname}  ${resp.json()['businessName']}
    # Set Test Variable  ${pid}  ${resp.json()['id']}
    # Set Test Variable  ${uniqueId}  ${resp.json()['uniqueId']}

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
    ${resp1}=   Run Keyword If  ${resp.json()['walkinConsumerBecomesJdCons']}==${bool[0]}   Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${EMPTY}
    Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.json()}
    Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}

    FOR   ${i}  IN RANGE   5
        # ${PO_Number1}    Generate random string    3    0123456789
        # ${PO_Number1}    Convert To Integer  ${PO_Number1}
        # ${CUSERPH0}=  Evaluate  ${CUSERNAME}+${PO_Number1}
        # ${PO_Number}=  random_phone_num_generator
        ${PO_Number}=  Get Random Valid Phone Number
        Log  ${PO_Number}
        ${country_code}=  Set Variable  ${PO_Number.country_code}
        ${CUSERPH0}=  Set Variable  ${PO_Number.national_number}
        ${keywordstatus} 	${value} = 	Run Keyword And Ignore Error   List Should Not Contain Value  ${numbers}  ${CUSERPH0}
        Log Many  ${keywordstatus} 	${value}
        Continue For Loop If  '${keywordstatus}' == 'FAIL'
        Run Keyword If  '${keywordstatus}' == 'PASS'  Append To List   ${numbers}  ${CUSERPH0}
        Exit For Loop IF   '${keywordstatus}' == 'PASS'
    END

    # FOR  ${i}  IN RANGE   3
    #     ${country_code}    Generate random string    2    0123456789
    #     Exit For Loop If  "${country_code}" != "91"
    # END
    
    
    # ${country_code}    Convert To Integer  ${country_code}
    # ${CUSERPH0}=  Evaluate  ${CUSERNAME}+${PO_Number1}
    # Append To File  ${EXECDIR}/TDD/numbers.txt  ${CUSERPH0}${\n}
    ${fname}=  FakerLibrary.first_name
    ${lname}=  FakerLibrary.last_name
    ${resp}=  AddCustomer  ${CUSERPH0}  firstName=${fname}  lastName=${lname}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}
    
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERPH0}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['id']}  ${cid}

    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${CUSERPH_SECOND}=  Evaluate  ${CUSERPH0}+1000
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}=  Random Element    ${Genderlist}
    ${CUSERPH0_EMAIL}=   Set Variable  ${C_Email}${lname}${country_code}.ynwtest@netvarth.com
    ${resp}=  Consumer SignUp  ${fname}  ${lname}  ${address}  ${CUSERPH0}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${CUSERPH0_EMAIL}   countryCode=+${country_code}
    Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    422
    # Should Be Equal As Strings  ${resp.json()}    ${INVALID_PHONE}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Activation  ${CUSERPH0_EMAIL}  ${OtpPurpose['ConsumerSignUp']}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Set Credential  ${CUSERPH0_EMAIL}  ${PASSWORD}  ${OtpPurpose['ConsumerSignUp']}  countryCode=+${country_code}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERPH0}  ${PASSWORD}  countryCode=+${country_code}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${jdconID}   ${resp.json()['id']}

    ${resp}=  Consumer Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    Append To File  ${EXECDIR}/TDD/consumernumbers.txt  ${CUSERPH0}${\n}


JD-TC-Consumer Signup-9
    [Documentation]   sign up a consumer with same country code as that specified when adding the consumer as customer

    ${resp}=  Encrypted Provider Login  ${PUSERNAME8}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${bname}  ${resp.json()['businessName']}
    # Set Test Variable  ${pid}  ${resp.json()['id']}
    # Set Test Variable  ${uniqueId}  ${resp.json()['uniqueId']}

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
    ${resp1}=   Run Keyword If  ${resp.json()['walkinConsumerBecomesJdCons']}==${bool[0]}   Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${EMPTY}
    Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.json()}
    Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}

    FOR   ${i}  IN RANGE   5
        # ${PO_Number1}    Generate random string    5    0123456789
        # ${PO_Number1}    Convert To Integer  ${PO_Number1}
        # ${CUSERPH0}=  Evaluate  ${CUSERNAME}+${PO_Number1}
        ${PO_Number}=  random_phone_num_generator
        Log  ${PO_Number}
        ${country_code}=  Set Variable  ${PO_Number.country_code}
        ${CUSERPH0}=  Set Variable  ${PO_Number.national_number}
        ${keywordstatus} 	${value} = 	Run Keyword And Ignore Error   List Should Not Contain Value  ${numbers}  ${CUSERPH0}
        Log Many  ${keywordstatus} 	${value}
        Continue For Loop If  '${keywordstatus}' == 'FAIL'
        Run Keyword If  '${keywordstatus}' == 'PASS'  Append To List   ${numbers}  ${CUSERPH0}
        Exit For Loop IF   '${keywordstatus}' == 'PASS'
    END

    # FOR  ${i}  IN RANGE   3
    #     ${country_code}    Generate random string    2    0123456789
    #     Exit For Loop If  "${country_code}" != "91"
    # END
    
    # ${PO_Number1}    Generate random string    5    0123456789
    # ${PO_Number1}    Convert To Integer  ${PO_Number1}
    # ${country_code}    Generate random string    2    0123456789
    # ${country_code}    Convert To Integer  ${country_code}
    # ${CUSERPH0}=  Evaluate  ${CUSERNAME}+${PO_Number1}
    # Append To File  ${EXECDIR}/TDD/numbers.txt  ${CUSERPH0}${\n}
    ${fname}=  FakerLibrary.first_name
    ${lname}=  FakerLibrary.last_name
    ${resp}=   AddCustomer  ${CUSERPH0}  countryCode=${country_code}  firstName=${fname}  lastName=${lname}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}
    
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERPH0}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['id']}  ${cid}

    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${CUSERPH_SECOND}=  Evaluate  ${CUSERPH0}+1000
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}=  Random Element    ${Genderlist}
    ${CUSERPH0_EMAIL}=   Set Variable  ${C_Email}${lname}${country_code}.ynwtest@netvarth.com
    ${resp}=  Consumer SignUp  ${fname}  ${lname}  ${address}  ${CUSERPH0}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${CUSERPH0_EMAIL}   countryCode=+${country_code}
    Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    422
    # Should Be Equal As Strings  ${resp.json()}    ${INVALID_PHONE}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Activation  ${CUSERPH0_EMAIL}  1
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Set Credential  ${CUSERPH0_EMAIL}  ${PASSWORD}  1  countryCode=+${country_code}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERPH0}  ${PASSWORD}  countryCode=+${country_code}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${jdconID}   ${resp.json()['id']}

    ${resp}=  Consumer Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    Append To File  ${EXECDIR}/TDD/consumernumbers.txt  ${CUSERPH0}${\n}


JD-TC-Consumer Signup-10
    [Documentation]   sign up a consumer with existing provider phone number but different country code
    
    # ${PO_Number}=  random_phone_num_generator
    ${PO_Number}=  Get Random Valid Phone Number
    Log  ${PO_Number}
    ${country_code}=  Set Variable  ${PO_Number.country_code}
    ${PUSERPH0}=  Set Variable  ${PO_Number.national_number}
    # ${PUSERPH0}=  Evaluate  ${PUSERNAME}+11025
    Set Suite Variable   ${PUSERPH0}
    ${resp}=   Run Keywords  clear_queue  ${PUSERPH0}   AND  clear_service  ${PUSERPH0}  AND  clear_Item    ${PUSERPH0}  AND   clear_Coupon   ${PUSERPH0}   AND  clear_Discount  ${PUSERPH0}
    ${licid}  ${licname}=  get_highest_license_pkg
    Log  ${licid}
    Log  ${licname}
    Set Suite Variable   ${licid}
    ${domresp}=  Get BusinessDomainsConf
    Log   ${domresp.content}
    Should Be Equal As Strings  ${domresp.status_code}  200
    ${dlen}=  Get Length  ${domresp.json()}
    ${d1}=  Random Int   min=0  max=${dlen-1}
    Set Suite Variable  ${dom}  ${domresp.json()[${d1}]['domain']}
    ${sdlen}=  Get Length  ${domresp.json()[${d1}]['subDomains']}
    ${sd1}=  Random Int   min=0  max=${sdlen-1}
    Set Suite Variable  ${sub_dom}  ${domresp.json()[${d1}]['subDomains'][${sd1}]['subDomain']}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ['Male', 'Female']
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${dom}  ${sub_dom}  ${PUSERPH0}  ${licid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Account Activation  ${PUSERPH0}  ${OtpPurpose['ProviderSignUp']}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.content}    "true"
    
    ${resp}=  Account Set Credential  ${PUSERPH0}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${pid}  ${decrypted_data['id']}
    # Set Test Variable  ${pid}  ${resp.json()['id']}

    Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERPH0}${\n}
    
    
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}  ${list}
    @{Views}=  Create List  self  all  customersOnly
    ${ph1}=  Evaluate  ${PUSERPH0}+1000000000
    ${ph2}=  Evaluate  ${PUSERPH0}+2000000000
    ${views}=  Evaluate  random.choice($Views)  random
    ${name1}=  FakerLibrary.name
    ${name2}=  FakerLibrary.name
    ${name3}=  FakerLibrary.name
    ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
    ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
    ${emails1}=  Emails  ${name3}  Email  ${P_Email}025.ynwtest@netvarth.com  ${views}
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
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${sTime}=  add_timezone_time  ${tz}  0  15  
    Set Suite Variable   ${sTime}
    ${eTime}=  add_timezone_time  ${tz}  0  45  
    Set Suite Variable   ${eTime}
    ${resp}=  Update Business Profile with Schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}   ${EMPTY}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get License UsageInfo 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${fields}=   Get subDomain level Fields  ${dom}  ${sub_dom}
    Log  ${fields.json()}
    Should Be Equal As Strings    ${fields.status_code}   200

    ${virtual_fields}=  get_Subdomainfields  ${fields.json()}

    ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${sub_dom}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get specializations Sub Domain  ${dom}  ${sub_dom}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${spec}=  get_Specializations  ${resp.json()}
    ${resp}=  Update Specialization  ${spec}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    Set Test Variable  ${email_id}  ${P_Email}${PUSERPH0}.ynwtest@netvarth.com

    ${resp}=  Update Email   ${p_id}   ${firstname}   ${lastname}   ${email_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${CUSERPH_SECOND}=  Evaluate  ${PUSERPH0}+1000
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    # ${country_code}    Generate random string    2    0123456789
    # ${country_code}    Convert To Integer  ${country_code}
    ${CUSERPH0_EMAIL}=   Set Variable  ${C_Email}${lastname}${country_code}.ynwtest@netvarth.com
    ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${PUSERPH0}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${CUSERPH0_EMAIL}  countryCode=+${country_code}
    Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    422
    # Should Be Equal As Strings  ${resp.json()}    ${INVALID_PHONE}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Consumer Activation  ${CUSERPH0_EMAIL}  ${OtpPurpose['ConsumerSignUp']}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Set Credential  ${CUSERPH0_EMAIL}  ${PASSWORD}  ${OtpPurpose['ConsumerSignUp']}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Login  ${PUSERPH0}  ${PASSWORD}  countryCode=${country_code}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    Append To File  ${EXECDIR}/TDD/consumernumbers.txt  ${PUSERNAME12}${\n}


JD-TC-Consumer Signup-UH3
    [Documentation]   Signup a Consumer with email address but no phone number

    ${PO_Number}    Generate random string    5    0123456789
    ${PO_Number}    Convert To Integer  ${PO_Number}
    ${CUSERPH2}=  Evaluate  ${CUSERPH}+${PO_Number}
    ${CUSERPH_SECOND}=  Evaluate  ${CUSERPH2}+1000
    ${CUSERMAIL2}=   Set Variable  ${C_Email}ph${CUSERPH2}.ynwtest@netvarth.com
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${EMPTY}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${CUSERMAIL2}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings  "${resp.json()}"    "${PRIMARY_PHONENO_REQUIRED}"
    # ${resp}=  Consumer Activation  ${CUSERMAIL2}  ${OtpPurpose['ConsumerSignUp']}
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # ${resp}=  Consumer Set Credential  ${CUSERMAIL2}  ${PASSWORD}  ${OtpPurpose['ConsumerSignUp']}
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # ${resp}=  Consumer Login  ${CUSERPH2}  ${PASSWORD}
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-Consumer Signup-UH4
    [Documentation]   Signup a Consumer with international number without email address

    # ${PO_Number}    Generate random string    4    0123456789
    # ${PO_Number}    Convert To Integer  ${PO_Number}
    # ${country_code}    Generate random string    2    0123456789
    # ${country_code}    Convert To Integer  ${country_code}
    # ${CUSERPH3}=  Evaluate  ${CUSERPH}+${PO_Number}
    # Append To File  ${EXECDIR}/TDD/numbers.txt  ${CUSERPH3}${\n}
    ${PO_Number}=  random_phone_num_generator
    Log  ${PO_Number}
    ${country_code}=  Set Variable  ${PO_Number.country_code}
    ${CUSERPH3}=  Set Variable  ${PO_Number.national_number}
    ${CUSERPH_SECOND}=  Evaluate  ${CUSERPH3}+1000
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    # ${CUSERPH3_EMAIL}=   Set Variable  ${C_Email}${lastname}${PO_Number}.ynwtest@netvarth.com
    ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${CUSERPH3}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${EMPTY}  countryCode=+${country_code}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings  "${resp.json()}"    "${EMAIL_ID_REQUIRED}"
    # ${resp}=  Consumer Activation  ${CUSERPH3}  ${OtpPurpose['ConsumerSignUp']}
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # ${resp}=  Consumer Set Credential  ${CUSERPH3}  ${PASSWORD}  ${OtpPurpose['ConsumerSignUp']}  countryCode=+${countryCode}
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # ${resp}=  Consumer Login  ${CUSERPH3}  ${PASSWORD}  countryCode=+${countryCode}
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200



JD-TC-Consumer Signup-11
    [Documentation]   sign up a provider consumer as consumer with walkinConsumerBecomesJdCons set as true.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME8}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${bname}  ${resp.json()['businessName']}
    # Set Test Variable  ${pid}  ${resp.json()['id']}
    # Set Test Variable  ${uniqueId}  ${resp.json()['uniqueId']}

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
    ${resp1}=   Run Keyword If  ${resp.json()['walkinConsumerBecomesJdCons']}==${bool[0]}   Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${EMPTY}
    Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.json()}
    Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}

    FOR   ${i}  IN RANGE   5
        ${PO_Number1}    Generate random string    5    0123456789
        ${PO_Number1}    Convert To Integer  ${PO_Number1}
        ${CUSERPH0}=  Evaluate  ${CUSERNAME}+${PO_Number1}
        ${keywordstatus} 	${value} = 	Run Keyword And Ignore Error   List Should Not Contain Value  ${numbers}  ${CUSERPH0}
        Log Many  ${keywordstatus} 	${value}
        Continue For Loop If  '${keywordstatus}' == 'FAIL'
        Run Keyword If  '${keywordstatus}' == 'PASS'  Append To List   ${numbers}  ${CUSERPH0}
        Exit For Loop IF   '${keywordstatus}' == 'PASS'
    END

    
    ${PO_Number1}    Generate random string    3    0123456789
    ${PO_Number1}    Convert To Integer  ${PO_Number1}
    ${CUSERPH0}=  Evaluate  ${CUSERNAME}+${PO_Number1}
    ${fname}=  FakerLibrary.first_name
    ${lname}=  FakerLibrary.last_name
    ${resp}=  AddCustomer  ${CUSERPH0}  firstName=${fname}  lastName=${lname}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}
    
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERPH0}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['id']}  ${cid}

    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${CUSERPH_SECOND}=  Evaluate  ${CUSERPH0}+1000
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}=  Random Element    ${Genderlist}
    ${resp}=  Consumer SignUp  ${fname}  ${lname}  ${address}  ${CUSERPH0}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${EMPTY} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # Should Be Equal As Strings  "${resp.json()}"    "${MOBILE_NO_USED}"

    ${resp}=  Consumer Activation  ${CUSERPH0}  ${OtpPurpose['ConsumerSignUp']}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Set Credential  ${CUSERPH0}  ${PASSWORD}  ${OtpPurpose['ConsumerSignUp']}  
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERPH0}  ${PASSWORD}  
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${jdconID}   ${resp.json()['id']}

    ${resp}=  Consumer Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    Append To File  ${EXECDIR}/TDD/consumernumbers.txt  ${CUSERPH0}${\n}


JD-TC-Consumer Signup-12
    [Documentation]   sign up a consumer with user's phone number.

    ${licId}  ${licname}=  get_highest_license_pkg
    ${buser}=   Get branch by license   ${licId}
    
    ${resp}=  Encrypted Provider Login  ${buser}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get License UsageInfo 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=   Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}

    ${resp}=  View Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Run Keyword If  ${resp.json()['filterByDept']}==${bool[0]}   Toggle Department Enable
    Run Keyword If  '${resp}' != '${None}'   Log  ${resp.content}
    Run Keyword If  '${resp}' != '${None}'   Should Be Equal As Strings  ${resp.status_code}  200
    
    sleep  2s
    ${dep_name1}=  FakerLibrary.bs
    ${dep_code1}=   Random Int  min=100   max=999
    ${dep_desc1}=   FakerLibrary.word  
    ${resp}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${dep_id}  ${resp.json()}

    ${PO_Number}    Generate random string    4    0123456789
    ${PO_Number}    Convert To Integer  ${PO_Number}
    ${PUSERPH0}=  Evaluate  ${PUSERNAME}+${PO_Number}
    clear_users  ${PUSERPH0}
    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}=  Random Element    ${Genderlist}
    # ${pin}=  get_pincode

    # ${resp}=  Get LocationsByPincode     ${pin}
    FOR    ${i}    IN RANGE    3
        ${pin}=  get_pincode
        ${kwstatus}  ${resp} = 	Run Keyword And Ignore Error  Get LocationsByPincode  ${pin}
        IF    '${kwstatus}' == 'FAIL'
                Continue For Loop
        ELSE IF    '${kwstatus}' == 'PASS'
                Exit For Loop
        END
    END
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${city}   ${resp.json()[0]['PostOffice'][0]['District']}   
    Set Test Variable  ${state}  ${resp.json()[0]['PostOffice'][0]['State']}      
    Set Test Variable  ${pin}    ${resp.json()[0]['PostOffice'][0]['Pincode']}    

    ${whpnum}=  Evaluate  ${PUSERPH0}+336245
    ${tlgnum}=  Evaluate  ${PUSERPH0}+336345

    ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERPH0}.ynwtest@netvarth.com   ${userType[0]}  ${pin}  ${countryCodes[0]}  ${PUSERPH0}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${countryCodes[0]}  ${whpnum}  ${countryCodes[0]}  ${tlgnum}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id}  ${resp.json()}

    ${resp}=  Get User By Id  ${u_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${u_id}  firstName=${firstname}  lastName=${lastname}  mobileNo=${PUSERPH0}

    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    # ${CUSERPH_SECOND}=  Evaluate  ${PUSERPH0}+1000
    ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${PUSERPH0}  ${EMPTY}  ${dob}  ${gender}   ${EMPTY} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Activation  ${PUSERPH0}  ${OtpPurpose['ConsumerSignUp']}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Set Credential  ${PUSERPH0}  ${PASSWORD}  ${OtpPurpose['ConsumerSignUp']}  
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${PUSERPH0}  ${PASSWORD}  
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    Append To File  ${EXECDIR}/TDD/consumernumbers.txt  ${PUSERPH0}${\n}


JD-TC-Consumer Signup-13
    [Documentation]   sign up a consumer with user's updated phone number.

    ${licId}  ${licname}=  get_highest_license_pkg
    ${buser}=   Get branch by license   ${licId}
    
    ${resp}=  Encrypted Provider Login  ${buser}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   Get License UsageInfo 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=   Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}

    ${resp}=  View Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Run Keyword If  ${resp.json()['filterByDept']}==${bool[0]}   Toggle Department Enable
    Run Keyword If  '${resp}' != '${None}'   Log  ${resp.content}
    Run Keyword If  '${resp}' != '${None}'   Should Be Equal As Strings  ${resp.status_code}  200
    
    sleep  2s
    ${dep_name1}=  FakerLibrary.bs
    ${dep_code1}=   Random Int  min=100   max=999
    ${dep_desc1}=   FakerLibrary.word  
    ${resp}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${dep_id}  ${resp.json()}
    
    # ${pin}=  get_pincode
    # Set Suite Variable  ${pin}

    # ${resp}=  Get LocationsByPincode     ${pin}
    # FOR    ${i}    IN RANGE    3
    #     ${pin}=  get_pincode
    #     ${kwstatus}  ${resp} = 	Run Keyword And Ignore Error  Get LocationsByPincode  ${pin}
    #     IF    '${kwstatus}' == 'FAIL'
    #             Continue For Loop
    #     ELSE IF    '${kwstatus}' == 'PASS'
    #             Exit For Loop
    #     END
    # END
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200 
    # Set Suite Variable  ${city}   ${resp.json()[0]['PostOffice'][0]['District']}   
    # Set Suite Variable  ${state}  ${resp.json()[0]['PostOffice'][0]['State']}      
    # Set Suite Variable  ${pin}    ${resp.json()[0]['PostOffice'][0]['Pincode']}    

    # ${PO_Number}    Generate random string    4    0123456789
    # ${PO_Number}    Convert To Integer  ${PO_Number}
    # ${PUSERPH0}=  Evaluate  ${PUSERNAME}+${PO_Number}
    # clear_users  ${PUSERPH0}
    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}=  Random Element    ${Genderlist}
    ${pin}=  get_pincode

    ${whpnum}=  Evaluate  ${PUSERPH0}+336245
    ${tlgnum}=  Evaluate  ${PUSERPH0}+336345
    
    # ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERPH0}.ynwtest@netvarth.com   ${userType[0]}  ${pin}  ${countryCodes[0]}  ${PUSERPH0}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${countryCodes[0]}  ${whpnum}  ${countryCodes[0]}  ${tlgnum}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${u_id}  ${resp.json()}
    
    ${u_id}=  Create Sample User
    Set Suite Variable  ${u_id}

    ${resp}=  Get User By Id  ${u_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response  ${resp}  id=${u_id}  firstName=${firstname}  lastName=${lastname}  mobileNo=${PUSERPH0}
    
    ${PO_Number}    Generate random string    4    0123456789
    ${PO_Number}    Convert To Integer  ${PO_Number}
    ${PUSERPH1}=  Evaluate  ${PUSERNAME}+${PO_Number}
    clear_users  ${PUSERPH1}

    ${resp}=  Update User  ${u_id}  ${firstname}  ${lastname}   ${dob}  ${gender}   ${P_Email}${PUSERPH1}.ynwtest@netvarth.com  ${userType[0]}  ${pin}  ${countryCodes[0]}   ${PUSERPH1}  ${dep_id}  ${sub_domain_id}   ${bool[0]}  ${countryCodes[0]}  ${whpnum}  ${countryCodes[0]}  ${tlgnum}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get User By Id  ${u_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${u_id}  firstName=${firstname}  lastName=${lastname}  mobileNo=${PUSERPH1}

    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    # ${CUSERPH_SECOND}=  Evaluate  ${PUSERPH0}+1000
    ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${PUSERPH1}  ${EMPTY}  ${dob}  ${gender}   ${EMPTY} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Activation  ${PUSERPH1}  ${OtpPurpose['ConsumerSignUp']}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Set Credential  ${PUSERPH1}  ${PASSWORD}  ${OtpPurpose['ConsumerSignUp']}  
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${PUSERPH1}  ${PASSWORD}  
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    Append To File  ${EXECDIR}/TDD/consumernumbers.txt  ${PUSERPH1}${\n}



# JD-TC-Verify Consumer Signup-3
#     [Documentation]   Verify Signup an existing consumer to a provider

#     ${resp}=  Encrypted Provider Login  ${CUSERPH0}  ${PASSWORD}
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200

#     ${resp}=  Get Business Profile
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
    
#     Verify Response  ${resp}  businessName=${bs}  businessDesc=${desc}  shortName=${companySuffix}  status=${status[0]}  createdDate=${DAY1}  licence=${pkg_name}  verifyLevel=${verifyLevel[0]}  enableSearch=${bool[0]}  accountLinkedPhNo=${CUSERPH0}  licensePkgID=${pkgId} 
#     Should Be Equal As Strings  ${resp.json()['serviceSector']['domain']}  ${d1}
#     Should Be Equal As Strings  ${resp.json()['serviceSubSector']['subDomain']}  ${sd1}
#     Should Be Equal As Strings  ${resp.json()['baseLocation']['place']}  ${city}
#     Should Be Equal As Strings  ${resp.json()['baseLocation']['longitude']}  ${longi}
#     Should Be Equal As Strings  ${resp.json()['baseLocation']['lattitude']}  ${latti}
#     Should Be Equal As Strings  ${resp.json()['baseLocation']['googleMapUrl']}  ${url}
#     Should Be Equal As Strings  ${resp.json()['baseLocation']['parkingType']}  ${parking}
#     Should Be Equal As Strings  ${resp.json()['baseLocation']['open24hours']}  ${bool[1]}
#     Should Be Equal As Strings  ${resp.json()['baseLocation']['bSchedule']['timespec'][0]['startDate']}  ${DAY1}
