** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        BusinessProfile
Library           Collections
Library           String
Library           json
Library           requests
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/consumerlist.py

*** Variables ***
@{Views}  self  all  customersOnly

*** Test Cases ***

JD-TC-CreateBusinessProfile-1
    [Documentation]  Create  business profile with no details of provider
    ${domresp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${domresp.status_code}  200
    ${len}=  Get Length  ${domresp.json()}
    ${len}=  Evaluate  ${len}-1
    Set Suite Variable  ${d1}  ${domresp.json()[${len}]['domain']}    
    Set Suite Variable  ${sd}  ${domresp.json()[${len}]['subDomains'][0]['subDomain']} 
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${PUSERNAME_B}=  Evaluate  ${PUSERNAME}+550021
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${d1}  ${sd}  ${PUSERNAME_B}    1
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAME_B}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAME_B}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_B}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
#     Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME_B}${\n}
#     Set Suite Variable  ${PUSERNAME_B}
#     ${DAY1}=  db.get_date_by_timezone  ${tz}
#     Set Suite Variable  ${DAY1}  ${DAY1}
#     ${list}=  Create List  1  2  3  4  5  6  7
#     Set Suite Variable  ${list}  ${list}
#     ${resp}=  Create Business Profile without details  ${EMPTY}  ${EMPTY}   ${EMPTY}  ${EMPTY}  ${EMPTY}  ${EMPTY}
#     Should Be Equal As Strings  ${resp.status_code}  200


# JD-TC-CreateBusinessProfile-2
#     [Documentation]  Create  business profile with no details of business name and business description
#     ${firstname}=  FakerLibrary.first_name
#     ${lastname}=  FakerLibrary.last_name
#     ${PUSERNAME_C}=  Evaluate  ${PUSERNAME}+550022
#     ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${d1}  ${sd}  ${PUSERNAME_C}    1
#     Log  ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${resp}=  Account Activation  ${PUSERNAME_C}  0
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${resp}=  Account Set Credential  ${PUSERNAME_C}  ${PASSWORD}  0
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${resp}=  Encrypted Provider Login  ${PUSERNAME_C}  ${PASSWORD}
#     Log  ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME_C}${\n}
#     Set Suite Variable  ${PUSERNAME_C}
#     ${companySuffix}=  FakerLibrary.companySuffix
#     Set Suite Variable  ${companySuffix}
#     ${ph1}=  Evaluate  ${PUSERNAME}+550023
#     Set Suite Variable  ${ph1}
#     ${ph2}=  Evaluate  ${PUSERNAME}+550024
#     Set Suite Variable  ${ph2}
#     ${views}=  Evaluate  random.choice($Views)  random
#     Set Suite Variable  ${Views}
#     ${name1}=  FakerLibrary.name
#     Set Suite Variable  ${name1}
#     ${name2}=  FakerLibrary.name
#     Set Suite Variable  ${name2}
#     ${name3}=  FakerLibrary.name
#     Set Suite Variable  ${name3}
#     ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
#     Set Suite Variable  ${ph_nos1}
#     ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
#     Set Suite Variable  ${ph_nos2}
#     ${emails1}=  Emails  ${name3}  Email  ${companySuffix}${P_Email}.${test_mail}  ${views}
#     Set Suite Variable  ${emails1}
#     ${resp}=  Create Business Profile without details  ${EMPTY}  ${EMPTY}   ${companySuffix}  ${ph_nos1}  ${ph_nos2}  ${emails1}
#     Should Be Equal As Strings  ${resp.status_code}  200
   
# JD-TC-CreateBusinessProfile-3
#     [Documentation]  Create  business profile with business name and business description
#     ${firstname}=  FakerLibrary.first_name
#     ${lastname}=  FakerLibrary.last_name
#     ${PUSERNAME_D}=  Evaluate  ${PUSERNAME}+550025
#     ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${d1}  ${sd}  ${PUSERNAME_D}    1
#     Log  ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${resp}=  Account Activation  ${PUSERNAME_D}  0
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${resp}=  Account Set Credential  ${PUSERNAME_D}  ${PASSWORD}  0
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${resp}=  Encrypted Provider Login  ${PUSERNAME_D}  ${PASSWORD}
#     Log  ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME_D}${\n}
#     Set Suite Variable  ${PUSERNAME_D}
#     ${bs}=  FakerLibrary.bs
#     Set Suite Variable  ${bs}
#     ${resp}=  Create Business Profile without details  ${bs}  ${bs} Desc  ${EMPTY}  ${EMPTY}  ${EMPTY}  ${EMPTY}
#     Should Be Equal As Strings  ${resp.status_code}  200

# JD-TC-CreateBusinessProfile-4
#     [Documentation]  Create  business profile with no base location details
#     ${firstname}=  FakerLibrary.first_name
#     ${lastname}=  FakerLibrary.last_name
#     ${PUSERNAME_E}=  Evaluate  ${PUSERNAME}+550026
#     ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${d1}  ${sd}  ${PUSERNAME_E}    1
#     Log  ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${resp}=  Account Activation  ${PUSERNAME_E}  0
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${resp}=  Account Set Credential  ${PUSERNAME_E}  ${PASSWORD}  0
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
#     Log  ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME_E}${\n}
#     Set Suite Variable  ${PUSERNAME_E}
#     ${resp}=  Create Business Profile without details  ${bs}  ${bs} Desc   ${companySuffix}  ${ph_nos1}  ${ph_nos2}  ${emails1}
#     Should Be Equal As Strings  ${resp.status_code}  200

# JD-TC-CreateBusinessProfile-5
#     [Documentation]  Create  business profile only with location details
#     ${firstname}=  FakerLibrary.first_name
#     ${lastname}=  FakerLibrary.last_name
#     ${PUSERNAME_F}=  Evaluate  ${PUSERNAME}+550027
#     ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${d1}  ${sd}  ${PUSERNAME_F}    1
#     Log  ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${resp}=  Account Activation  ${PUSERNAME_F}  0
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${resp}=  Account Set Credential  ${PUSERNAME_F}  ${PASSWORD}  0
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${resp}=  Encrypted Provider Login  ${PUSERNAME_F}  ${PASSWORD}
#     Log  ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME_F}${\n}
#     Set Suite Variable  ${PUSERNAME_F}
#     ${city}=   get_place
#     Set Suite Variable  ${city}
#     ${latti}=  get_latitude
#     Set Suite Variable  ${latti}
#     ${longi}=  get_longitude
#     Set Suite Variable  ${longi}
#     ${postcode}=  FakerLibrary.postcode
#     Set Suite Variable  ${postcode}
#     ${address}=  get_address
#     Set Suite Variable  ${address}
#     ${parking_type}    Random Element     ['none','free','street','privatelot','valet','paid']
#     Set Suite Variable  ${parking_type}
#     ${24hours}    Random Element    ['True','False']
#     Set Suite Variable  ${24hours}
#     ${resp}=  Create Business Profile with location only   ${EMPTY}   ${EMPTY}   ${EMPTY}  $[city]  ${longi}  ${latti}  www.${city}.com  ${parking_type}  ${24hours}  ${postcode}  ${address}  
#     Should Be Equal As Strings  ${resp.status_code}  200


# JD-TC-CreateBusinessProfile-6
#     [Documentation]  Create  business profile only with already existing same location details
#     ${resp}=  Encrypted Provider Login  ${PUSERNAME_F}  ${PASSWORD}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${resp}=  Create Business Profile with location only   ${EMPTY}   ${EMPTY}   ${EMPTY}  ${city}  ${longi}  ${latti}  www.${city}.com  ${parking_type}  ${24hours}  ${postcode}  ${address}  
#     Should Be Equal As Strings  ${resp.status_code}  200

# JD-TC-CreateBusinessProfile-7
#     [Documentation]  Create  business profile only with already existing  location with different values
#     ${firstname}=  FakerLibrary.first_name
#     ${lastname}=  FakerLibrary.last_name
#     ${PUSERNAME_G}=  Evaluate  ${PUSERNAME}+550028
#     ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${d1}  ${sd}  ${PUSERNAME_G}    1
#     Log  ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${resp}=  Account Activation  ${PUSERNAME_G}  0
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${resp}=  Account Set Credential  ${PUSERNAME_G}  ${PASSWORD}  0
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${resp}=  Encrypted Provider Login  ${PUSERNAME_G}  ${PASSWORD}
#     Log  ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME_G}${\n}
#     Set Suite Variable  ${PUSERNAME_G}
#     ${resp}=  Create Business Profile with location only   ${EMPTY}   ${EMPTY}   ${EMPTY}  ${city}  ${longi}  ${latti}  www.${city}.com  ${parking_type}  ${24hours}  ${postcode}  ${address}  
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${latti1}=  get_latitude
#     Set Suite Variable  ${latti1}
#     ${longi1}=  get_longitude
#     Set Suite Variable  ${longi1}
#     ${postcode1}=  FakerLibrary.postcode
#     Set Suite Variable  ${postcode1}
#     ${address1}=  get_address
#     Set Suite Variable  ${address1}
#     ${parking_type1}    Random Element     ['none','free','street','privatelot','valet','paid']
#     Set Suite Variable  ${parking_type1}
#     ${24hours1}    Random Element    ['True','False']
#     Set Suite Variable  ${24hours1}
#     ${resp}=  Create Business Profile with location only   ${EMPTY}   ${EMPTY}   ${EMPTY}  ${city}  ${longi1}  ${latti1}  www.${city}.com  ${parking_type1}  ${24hours1}  ${postcode1}  ${address1}
#     Should Be Equal As Strings  ${resp.status_code}  200

# JD-TC-CreateBusinessProfile-8
#     [Documentation]  Create  business profile for a valid user without schedule
#     ${firstname}=  FakerLibrary.first_name
#     ${lastname}=  FakerLibrary.last_name
#     ${PUSERNAME_H}=  Evaluate  ${PUSERNAME}+550029
#     ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${d1}  ${sd}  ${PUSERNAME_H}    1
#     Log  ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${resp}=  Account Activation  ${PUSERNAME_H}  0
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${resp}=  Account Set Credential  ${PUSERNAME_H}  ${PASSWORD}  0
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${resp}=  Encrypted Provider Login  ${PUSERNAME_H}  ${PASSWORD}
#     Log  ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME_H}${\n}
#     Set Suite Variable  ${PUSERNAME_H}
#     ${city8}=   get_place
#     Set Suite Variable  ${city8}
#     ${latti8}=  get_latitude
#     Set Suite Variable  ${latti8}
#     ${longi8}=  get_longitude
#     Set Suite Variable  ${longi8}
#     ${postcode8}=  FakerLibrary.postcode
#     Set Suite Variable  ${postcode8}
#     ${address8}=  get_address
#     Set Suite Variable  ${address8}
#     ${parking_type8}    Random Element     ['none','free','street','privatelot','valet','paid']
#     Set Suite Variable  ${parking_type8}
#     ${24hours8}    Random Element    ['True','False']
#     Set Suite Variable  ${24hours8}
#     ${resp}=  Create Location without schedule  ${city8}  ${longi8}  ${latti8}  www.${city8}.com  ${postcode8}  ${address8}  ${parking_type8}  ${24hours8}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Suite Variable  ${lid8}  ${resp.json()}
#     ${resp}=  Create Business Profile without schedule   ${bs}  ${bs} Desc   ${companySuffix}  ${city8}  ${longi8}  ${latti8}  www.${city8}.com  ${parking_type8}  ${24hours8}  ${postcode8}  ${address8}  ${ph_nos1}  ${ph_nos2}  ${emails1}  ${lid8}
#     Should Be Equal As Strings  ${resp.status_code}  200

# JD-TC-CreateBusinessProfile-9
#     [Documentation]  Create  business profile only with location schedule
#     ${firstname}=  FakerLibrary.first_name
#     ${lastname}=  FakerLibrary.last_name
#     ${PUSERNAME_I}=  Evaluate  ${PUSERNAME}+550030
#     ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${d1}  ${sd}  ${PUSERNAME_I}    1
#     Log  ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${resp}=  Account Activation  ${PUSERNAME_I}  0
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${resp}=  Account Set Credential  ${PUSERNAME_I}  ${PASSWORD}  0
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${resp}=  Encrypted Provider Login  ${PUSERNAME_I}  ${PASSWORD}
#     Log  ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME_I}${\n}
#     Set Suite Variable  ${PUSERNAME_I}
#     ${sTime9}=  add_timezone_time  ${tz}  1  0  
#     Set Suite Variable   ${sTime9}
#     ${eTime9}=  add_timezone_time  ${tz}  1  50  
#     Set Suite Variable   ${eTime9}
#     ${resp}=  Create Business Profile  ${EMPTY}   ${EMPTY}   ${EMPTY}  ${EMPTY}   ${EMPTY}  ${EMPTY}  ${EMPTY}  free  True  Weekly  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime9}  ${eTime9}  ${EMPTY}  ${EMPTY}  ${EMPTY}  ${EMPTY}  ${EMPTY}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200

# JD-TC-CreateBusinessProfile-10
#     [Documentation]  Create  business profile  with overlapping location schedule(there is no overlapping checking in location schedule)
#     ${resp}=  Encrypted Provider Login  ${PUSERNAME_I}  ${PASSWORD}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${sTime10}=  add_timezone_time  ${tz}  1  30  
#     Set Suite Variable   ${sTime10}
#     ${eTime10}=  add_timezone_time  ${tz}  2  50  
#     Set Suite Variable   ${eTime10}
#     ${resp}=  Create Business Profile  ${EMPTY}   ${EMPTY}   ${EMPTY}  ${EMPTY}   ${EMPTY}  ${EMPTY}  ${EMPTY}  free  True  Weekly  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime10}  ${eTime10}  ${EMPTY}  ${EMPTY}  ${EMPTY}  ${EMPTY}  ${EMPTY}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200

# JD-TC-CreateBusinessProfile-11
#     [Documentation]  Create  business profile with same location schedule
#     ${firstname}=  FakerLibrary.first_name
#     ${lastname}=  FakerLibrary.last_name
#     ${PUSERNAME_J}=  Evaluate  ${PUSERNAME}+550031
#     ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${d1}  ${sd}  ${PUSERNAME_J}    1
#     Log  ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${resp}=  Account Activation  ${PUSERNAME_J}  0
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${resp}=  Account Set Credential  ${PUSERNAME_J}  ${PASSWORD}  0
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${resp}=  Encrypted Provider Login  ${PUSERNAME_J}  ${PASSWORD}
#     Log  ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME_J}${\n}
#     Set Suite Variable  ${PUSERNAME_J}
#     ${sTime11}=  add_timezone_time  ${tz}  1  0  
#     Set Suite Variable   ${sTime11}
#     ${eTime11}=  add_time   1  80
#     Set Suite Variable   ${eTime11}
#     ${resp}=  Create Business Profile  ${EMPTY}   ${EMPTY}   ${EMPTY}  ${EMPTY}   ${EMPTY}  ${EMPTY}  ${EMPTY}  free  True  Weekly  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime11}  ${eTime11}  ${EMPTY}  ${EMPTY}  ${EMPTY}  ${EMPTY}  ${EMPTY}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${resp}=  Create Business Profile  ${EMPTY}   ${EMPTY}   ${EMPTY}  ${EMPTY}   ${EMPTY}  ${EMPTY}  ${EMPTY}  free  True  Weekly  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime11}  ${eTime11}  ${EMPTY}  ${EMPTY}  ${EMPTY}  ${EMPTY}  ${EMPTY}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200

# JD-TC-CreateBusinessProfile-UH3
#     [Documentation]  Create  business profile without login
#     ${resp}=  Create Business Profile   ${bs}  ${bs} Desc   ${companySuffix}  ${city}  ${longi}  ${latti}  www.${city}.com  ${parking_type}  ${24hours}  Weekly  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime9}  ${eTime9}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}
#     Should Be Equal As Strings  ${resp.status_code}   419
#     Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"
      
# JD-TC-CreateBusinessProfile-UH4
#     [Documentation]  Create  business profile using comsumer login
#     ${resp}=  ConsumerLogin  ${CUSERNAME1}  ${PASSWORD}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${resp}=  Create Business Profile   ${bs}  ${bs} Desc   ${companySuffix}  ${city}  ${longi}  ${latti}  www.${city}.com  ${parking_type}  ${24hours}  Weekly  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime9}  ${eTime9}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}
#     Should Be Equal As Strings  ${resp.status_code}   401
#     Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"

#     sleep  06s
# JD-TC-VerifyCreateBusinessProfile-1
# 	[Documentation]  Verification of get business profile of ${PUSERNAME_B}
#     ${resp}=  Encrypted Provider Login  ${PUSERNAME_B}  ${PASSWORD}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${resp}=  Get Business Profile
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Verify Response  ${resp}  businessName=${EMPTY}  businessDesc=${EMPTY}  shortName=${EMPTY}  status=INACTIVE  createdDate=${DAY1}
#     Should Be Equal As Strings  ${resp.json()['serviceSector']['domain']}  ${d1}
#     Should Be Equal As Strings  ${resp.json()['serviceSubSector']['subDomain']}  ${sd}
#     Should Be Equal As Strings  ${resp.json()['emails'][0]}  ${EMPTY}
#     Should Be Equal As Strings  ${resp.json()['phoneNumbers'][0]}  ${EMPTY}
#     Should Be Equal As Strings  ${resp.json()['phoneNumbers'][1]}  ${EMPTY}

# JD-TC-VerifyCreateBusinessProfile-2
# 	[Documentation]  Verification of get business profile of ${PUSERNAME_C}
#     ${resp}=  Encrypted Provider Login  ${PUSERNAME_C}  ${PASSWORD}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${resp}=  Get Business Profile
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Verify Response  ${resp}  businessName=${EMPTY}  businessDesc=${EMPTY}  shortName=${companySuffix}  status=INACTIVE  createdDate=${DAY1}
#     Should Be Equal As Strings  ${resp.json()['serviceSector']['domain']}  ${d1}
#     Should Be Equal As Strings  ${resp.json()['serviceSubSector']['subDomain']}  ${sd}
#     Should Be Equal As Strings  ${resp.json()['emails'][0]['label']}  ${name3}
#     Should Be Equal As Strings  ${resp.json()['emails'][0]['instance']}  ${companySuffix}${P_Email}.${test_mail}
#     Should Be Equal As Strings  ${resp.json()['phoneNumbers'][0]['label']}  ${name1}
#     Should Be Equal As Strings  ${resp.json()['phoneNumbers'][0]['instance']}  ${ph1}
#     Should Be Equal As Strings  ${resp.json()['phoneNumbers'][1]['label']}  ${name2}
#     Should Be Equal As Strings  ${resp.json()['phoneNumbers'][1]['instance']}  ${ph2} 

# JD-TC-VerifyCreateBusinessProfile-3
# 	[Documentation]  Verification of get business profile of ${PUSERNAME_D}
#     ${resp}=  Encrypted Provider Login  ${PUSERNAME_D}  ${PASSWORD}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${resp}=  Get Business Profile
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Verify Response  ${resp}  businessName=${bs}  businessDesc=${bs} Desc  shortName=${EMPTY}  status=INACTIVE  createdDate=${DAY1}
#     Should Be Equal As Strings  ${resp.json()['serviceSector']['domain']}  ${d1}
#     Should Be Equal As Strings  ${resp.json()['serviceSubSector']['subDomain']}  ${sd}
#     Should Be Equal As Strings  ${resp.json()['emails'][0]}  ${EMPTY}
#     Should Be Equal As Strings  ${resp.json()['phoneNumbers'][0]}  ${EMPTY}
#     Should Be Equal As Strings  ${resp.json()['phoneNumbers'][1]}  ${EMPTY}

# JD-TC-VerifyCreateBusinessProfile-4
# 	[Documentation]  Verification of get business profile of ${PUSERNAME_E}
#     ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${resp}=  Get Business Profile
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Verify Response  ${resp}  businessName=${bs}  businessDesc=${bs} Desc  shortName=${companySuffix}  status=INACTIVE  createdDate=${DAY1}
#     Should Be Equal As Strings  ${resp.json()['serviceSector']['domain']}  ${d1}
#     Should Be Equal As Strings  ${resp.json()['serviceSubSector']['subDomain']}  ${sd}
#     Should Be Equal As Strings  ${resp.json()['emails'][0]['label']}  ${name3}
#     Should Be Equal As Strings  ${resp.json()['emails'][0]['instance']}  ${companySuffix}${P_Email}.${test_mail}
#     Should Be Equal As Strings  ${resp.json()['phoneNumbers'][0]['label']}  ${name1}
#     Should Be Equal As Strings  ${resp.json()['phoneNumbers'][0]['instance']}  ${ph1}
#     Should Be Equal As Strings  ${resp.json()['phoneNumbers'][1]['label']}  ${name2}
#     Should Be Equal As Strings  ${resp.json()['phoneNumbers'][1]['instance']}  ${ph2} 

# JD-TC-VerifyCreateBusinessProfile-6
# 	[Documentation]  Verification of get business profile of ${PUSERNAME_F}
#     ${resp}=  Encrypted Provider Login  ${PUSERNAME_F}  ${PASSWORD}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${resp}=  Get Business Profile
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Verify Response  ${resp}  businessName=${EMPTY}  businessDesc=${EMPTY}  shortName=${EMPTY}  status=ACTIVE  createdDate=${DAY1}
#     Should Be Equal As Strings  ${resp.json()['serviceSector']['domain']}  ${d1}
#     Should Be Equal As Strings  ${resp.json()['serviceSubSector']['subDomain']}  ${sd}
#     Should Be Equal As Strings  ${resp.json()['baseLocation']['place']}  ${city}
#     Should Be Equal As Strings  ${resp.json()['baseLocation']['longitude']}  ${longi}
#     Should Be Equal As Strings  ${resp.json()['baseLocation']['lattitude']}  ${latti}
#     Should Be Equal As Strings  ${resp.json()['baseLocation']['googleMapUrl']}  www.${city}.com
#     Should Be Equal As Strings  ${resp.json()['baseLocation']['parkingType']}  ${parking_type}
#     Should Be Equal As Strings  ${resp.json()['baseLocation']['open24hours']}  ${24hours}

# JD-TC-VerifyCreateBusinessProfile-7
# 	[Documentation]  Verification of get business profile of ${PUSERNAME_G}
#     ${resp}=  Encrypted Provider Login  ${PUSERNAME_G}  ${PASSWORD}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${resp}=  Get Business Profile
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Verify Response  ${resp}  businessName=${EMPTY}  businessDesc=${EMPTY}  shortName=${EMPTY}  status=ACTIVE  createdDate=${DAY1}
#     Should Be Equal As Strings  ${resp.json()['serviceSector']['domain']}  ${d1}
#     Should Be Equal As Strings  ${resp.json()['serviceSubSector']['subDomain']}  ${sd}
#     Should Be Equal As Strings  ${resp.json()['baseLocation']['place']}  ${city}
#     Should Be Equal As Strings  ${resp.json()['baseLocation']['longitude']}  ${longi1}
#     Should Be Equal As Strings  ${resp.json()['baseLocation']['lattitude']}  ${latti1}
#     Should Be Equal As Strings  ${resp.json()['baseLocation']['googleMapUrl']}  www.${city}.com
#     Should Be Equal As Strings  ${resp.json()['baseLocation']['parkingType']}  ${parking_type1}
#     Should Be Equal As Strings  ${resp.json()['baseLocation']['open24hours']}  ${24hours1}   

# JD-TC-VerifyCreateBusinessProfile-8
# 	[Documentation]  Verification of get business profile of ${PUSERNAME_H}
#     ${resp}=  Encrypted Provider Login  ${PUSERNAME_H}  ${PASSWORD}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${resp}=  Get Business Profile
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Verify Response  ${resp}  businessName=${bs}  businessDesc=${bs} Desc  shortName=${companySuffix}  status=ACTIVE  createdDate=${DAY1}
#     Should Be Equal As Strings  ${resp.json()['serviceSector']['domain']}  ${d1}
#     Should Be Equal As Strings  ${resp.json()['serviceSubSector']['subDomain']}  ${sd}
#     Should Be Equal As Strings  ${resp.json()['emails'][0]['label']}  ${name3}
#     Should Be Equal As Strings  ${resp.json()['emails'][0]['instance']}  ${companySuffix}${P_Email}.${test_mail}
#     Should Be Equal As Strings  ${resp.json()['phoneNumbers'][0]['label']}  ${name1}
#     Should Be Equal As Strings  ${resp.json()['phoneNumbers'][0]['instance']}  ${ph1}
#     Should Be Equal As Strings  ${resp.json()['phoneNumbers'][1]['label']}  ${name2}
#     Should Be Equal As Strings  ${resp.json()['phoneNumbers'][1]['instance']}  ${ph2} 
#     Should Be Equal As Strings  ${resp.json()['baseLocation']['id']}  ${lid8}
#     Should Be Equal As Strings  ${resp.json()['baseLocation']['place']}  ${city8}
#     Should Be Equal As Strings  ${resp.json()['baseLocation']['longitude']}  ${longi8}
#     Should Be Equal As Strings  ${resp.json()['baseLocation']['lattitude']}  ${latti8}
#     Should Be Equal As Strings  ${resp.json()['baseLocation']['googleMapUrl']}  www.${city8}.com
#     Should Be Equal As Strings  ${resp.json()['baseLocation']['parkingType']}  ${parking_type8}
#     Should Be Equal As Strings  ${resp.json()['baseLocation']['open24hours']}  ${24hours8}   

# JD-TC-VerifyCreateBusinessProfile-9
# 	[Documentation]  Verification of get business profile of ${PUSERNAME_I}(case 9 and case 10)
#     ${resp}=  Encrypted Provider Login  ${PUSERNAME_I}  ${PASSWORD}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${resp}=  Get Business Profile  
#     Log  ${resp.json()} 
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Verify Response  ${resp}  businessName=${EMPTY}  businessDesc=${EMPTY}  shortName=${EMPTY}  status=ACTIVE  createdDate=${DAY1}
#     Should Be Equal As Strings  ${resp.json()['serviceSector']['domain']}  ${d1}
#     Should Be Equal As Strings  ${resp.json()['serviceSubSector']['subDomain']}  ${sd}
#     Should Be Equal As Strings  ${resp.json()['baseLocation']['place']}  ${EMPTY}
#     Should Be Equal As Strings  ${resp.json()['baseLocation']['longitude']}  ${EMPTY}
#     Should Be Equal As Strings  ${resp.json()['baseLocation']['lattitude']}  ${EMPTY}
#     Should Be Equal As Strings  ${resp.json()['baseLocation']['googleMapUrl']}  ${EMPTY}
#     Should Be Equal As Strings  ${resp.json()['baseLocation']['bSchedule']['timespec'][0]['recurringType']}  Weekly
#     Should Be Equal As Strings  ${resp.json()['baseLocation']['bSchedule']['timespec'][0]['repeatIntervals']}  ${list}
#     Should Be Equal As Strings  ${resp.json()['baseLocation']['bSchedule']['timespec'][0]['startDate']}  ${DAY1}
#     Should Be Equal As Strings  ${resp.json()['baseLocation']['bSchedule']['timespec'][0]['timeSlots'][0]['sTime']}  ${sTime10}
#     Should Be Equal As Strings  ${resp.json()['baseLocation']['bSchedule']['timespec'][0]['timeSlots'][0]['eTime']}  ${eTime10}

# JD-TC-VerifyCreateBusinessProfile-UH2
#     [Documentation]  Create  business profile with same location schedule
#     ${resp}=  Encrypted Provider Login  ${PUSERNAME_J}  ${PASSWORD}
#     Log  ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${resp}=  Get Business Profile  
#     Log  ${resp.json()} 
#     Should Be Equal As Strings  ${resp.status_code}  200