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
Resource          /ebs/TDD/NotificationKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot


*** Variables ***

${firstname}    Simi
${lastname}     Sabu
${conEmail1simi}    simi.sabu@netvarth.com
${EmailProConsreshma}    reshma.mohan@netvarth.com
${Emailhisham}       mohammed.hisham@netvarth.com
${emailsimi}        simicsabu63@gmail.com
${usermail}         simi.${test_mail}
${ConsMobilenum}     9605118778  
${MobilenumHi}       6282559238
${MobilenumRIA}    9995805992
${EmailRaigan}    raigan.ar@nevarth.com
${countryCode}  +91   
${internatcountryCode}  +44
${internatMobNum}    7911123453
${PASSWORD}     JaldeeJTA@123
${PASSWORD1}    SimicSabu
${PASSWORD2}    SimiSabu@123
${NewPASSWORD}  reshma@123
${NEW_PASSWORD12}   Hisham123@S
${MobilenumHi122}          8943906416
${self}            0
${pngfile}     /ebs/TDD/upload.png
${jpgfile}     /ebs/TDD/uploadimage.jpg
${filesize}    0.0084
${PASSWORDuser1}      SumiSimy12@
${PASSWORDuser2}      SumiSimy12@123
${start}              100
@{multiples}  10  20  30   40   50
${pdffile}      /ebs/TDD/sample.pdf
${PASSWORDorder}    Ssbu34@fjj
${service_duration}   2
${parallel}           1

***Keywords***


Get Non Billable Subdomain
    [Arguments]   ${domain}  ${jsondata}  ${posval}  
    ${length}=  Get Length  ${jsondata.json()[${posval}]['subDomains']}
    FOR  ${pos}  IN RANGE  ${length}
            Set Test Variable  ${subdomain}  ${jsondata.json()[${posval}]['subDomains'][${pos}]['subDomain']}
            ${resp}=   Get Sub Domain Settings    ${domain}    ${subdomain}
            Should Be Equal As Strings    ${resp.status_code}    200
            Exit For Loop IF  '${resp.json()['serviceBillable']}' == '${bool[0]}'
    END
    RETURN  ${subdomain}  ${resp.json()['serviceBillable']}

Get branch by license
    [Arguments]   ${lic_id}
    
    ${resp}=   Get File    ${EXECDIR}/TDD/varfiles/providers.py
    ${len}=   Split to lines  ${resp}
    ${length}=  Get Length   ${len}
     
    FOR   ${a***}  IN RANGE  ${length}
            
        ${Branch_PH}=  Set Variable  ${PUSERNAME${a}}
        ${resp}=  Encrypted Provider Login  ${PUSERNAME${a}}  ${PASSWORD}
        Should Be Equal As Strings    ${resp.status_code}    200
        ${domain}=   Set Variable    ${resp.json()['sector']}
        ${subdomain}=    Set Variable      ${resp.json()['subSector']}
        ${resp}=   Get Active License
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}   200
        ${pkg_id}=   Set Variable  ${resp.json()['accountLicense']['licPkgOrAddonId']}
        ${pkg_name}=   Set Variable  ${resp.json()['accountLicense']['name']}
	    # Run Keyword IF   ${resp.json()['accountLicense']['licPkgOrAddonId']} == ${lic_id}   AND   ${resp.json()['accountLicense']['name']} == ${lic_name}   Exit For Loop
        Exit For Loop IF  ${resp.json()['accountLicense']['licPkgOrAddonId']} == ${lic_id}

    END
    RETURN  ${Branch_PH}


Billable

    ${resp}=   Get File    /ebs/TDD/varfiles/providers.py
    ${len}=   Split to lines  ${resp}
    ${length}=  Get Length   ${len}
     
    FOR   ${a}  IN RANGE  ${start}   ${length}
            
        ${resp}=  Encrypted Provider Login  ${ConsMobilenum}  ${PASSWORD}
        Should Be Equal As Strings    ${resp.status_code}    200
        ${decrypted_data}=  db.decrypt_data  ${resp.content}
        Log  ${decrypted_data}
        Set Suite Variable  ${PUSERNAME_PH}  ${decrypted_data['primaryPhoneNumber']}
        # Set Suite Variable  ${PUSERNAME_PH}  ${resp.json()['primaryPhoneNumber']}
        clear_location   ${ConsMobilenum}
        clear_service    ${ConsMobilenum}
        ${acc_id}=  get_acc_id  ${ConsMobilenum}
        Set Suite Variable   ${acc_id}
        ${domain}=   Set Variable    ${resp.json()['sector']}
        ${subdomain}=    Set Variable      ${resp.json()['subSector']}
        ${resp}=   Get Active License
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}   200
        ${resp}=   Get Queues
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}   200
        ${resp}=   Get Service
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=  Get Account Settings
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        IF  ${resp.json()['onlinePayment']}==${bool[0]}   
        ${resp}=   Enable Disable Online Payment   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

        ${resp}=  Get Account Settings
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        
        ${GST_num}  ${pan_num}=   db.Generate_gst_number   ${Container_id}
        ${resp}=  Update Tax Percentage  ${gstpercentage[3]}  ${GST_num} 
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}   200
        
        ${resp}=  Enable Tax
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}   200

        ${resp}=  View Waitlist Settings
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200
        IF  ${resp.json()['filterByDept']}==${bool[1]}
            ${resp}=  Toggle Department Disable
            Log  ${resp.content}
            Should Be Equal As Strings  ${resp.status_code}  200

        END 
        ${resp2}=   Get Sub Domain Settings    ${domain}    ${subdomain}
        Should Be Equal As Strings    ${resp.status_code}    200
        delete_donation_service  ${ConsMobilenum}
        Set Suite Variable  ${check}    ${resp2.json()['serviceBillable']} 
        Run Keyword IF   '${check}' == 'True'   clear_service       ${ConsMobilenum}
        Exit For Loop IF     '${check}' == 'True'

    END  
*** Test Cases ***                                                                     

# JD-TC-Consumer Signup Without Email-1
#     #  consumer signup ok
#     [Documentation]   Create consumer with all valid attributes except email
    
#     ${resp}=  Consumer SignUp Notification   ${firstname}  ${lastname}    ${ConsMobilenum}    ${countryCode}  
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${resp}=  Consumer Activation  ${ConsMobilenum}  1
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${resp}=  Consumer Set Credential  ${ConsMobilenum}  ${PASSWORD}  1
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${resp}=  Consumer Login  ${ConsMobilenum}  ${PASSWORD}
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200

#     Append To File  ${EXECDIR}/data/TDD_Logs/consumernumbers.txt  ${ConsMobilenum}${\n}
# *** Comments ***
# # JD-TC-Consumer Signup With Email-2


# #     [Documentation]   Create consumer  with email (internationalphone number) - its okey
    
# #      Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${internatMobNum}${\n}
   
# #     ${resp}=  Consumer SignUp Notification    ${firstname}   ${lastname}    ${internatMobNum}     ${internatcountryCode}   email=${conEmail1simi}
# #     Log  ${resp.content}
# #     Should Be Equal As Strings    ${resp.status_code}    200
# #     ${resp}=  Consumer Activation  ${conEmail1simi}  1
# #     Log  ${resp.content}
# #     Should Be Equal As Strings    ${resp.status_code}    200
# #     ${resp}=  Consumer Set Credential Notification    ${conEmail1simi}   ${PASSWORD1}   1   ${internatcountryCode}
# #     Log  ${resp.content}
# #     Should Be Equal As Strings    ${resp.status_code}    200
# #     ${resp}=  Consumer Login Notification   ${internatMobNum}   ${PASSWORD1}   ${internatcountryCode}
# #     Log  ${resp.content}
# #     Should Be Equal As Strings    ${resp.status_code}    200

# #     Append To File  ${EXECDIR}/data/TDD_Logs/consumernumbers.txt  ${conEmail1simi}${\n}

# JD-TC-Consumer Signup With Email-3

#     [Documentation]   Create consumer  with email - its ok
    
#      Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${MobilenumHi}${\n}
   
#     ${resp}=  Consumer SignUp Notification    ${firstname}   ${lastname}    ${MobilenumHi}     ${countryCode}   email=${Emailhisham}
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${resp}=  Consumer Activation  ${Emailhisham}  1
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${resp}=  Consumer Set Credential Notification    ${Emailhisham}   ${PASSWORD1}   1   ${countryCode}
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${resp}=  Consumer Login Notification   ${MobilenumHi}   ${PASSWORD1}   ${countryCode}
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200

#     Append To File  ${EXECDIR}/data/TDD_Logs/consumernumbers.txt  ${MobilenumHi}${\n}

# # *** Comments ***

# JD-TC-Provider_Signup-1

#     [Documentation]    Create a provider without email
#     ${domresp}=  Get BusinessDomainsConf
#     Log  ${domresp.json()}
#     Should Be Equal As Strings  ${domresp.status_code}  200
#     ${len}=  Get Length  ${domresp.json()}
#     ${domain_list}=  Create List
#     ${subdomain_list}=  Create List
#     FOR  ${domindex}  IN RANGE  ${len}
#         Set Test Variable  ${d}  ${domresp.json()[${domindex}]['domain']}    
#         Append To List  ${domain_list}    ${d} 
#         Set Test Variable  ${sd}  ${domresp.json()[${domindex}]['subDomains'][0]['subDomain']}
#         Append To List  ${subdomain_list}    ${sd} 
#     END
#     Log  ${domain_list}
#     Log  ${subdomain_list}
#     Set Suite Variable  ${domain_list}
#     Set Suite Variable  ${subdomain_list}
#     Set Test Variable  ${d1}  ${domain_list[0]}
#     Set Test Variable  ${sd1}  ${subdomain_list[0]}
#     # ${ph}=  Evaluate  ${PUSERNAME}+5666554
#     # Set Suite Variable  ${ph}
#     # ${firstname}=  FakerLibrary.first_name
#     # ${lastname}=  FakerLibrary.last_name
#     ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${d1}  ${sd1}  ${ConsMobilenum}   1
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${resp}=  Account Activation  ${ConsMobilenum}  0
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${resp}=  Account Set Credential  ${ConsMobilenum}  ${PASSWORD2}  0
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${resp}=  Encrypted Provider Login  ${ConsMobilenum}  ${PASSWORD2}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${ConsMobilenum}${\n}


# JD-TC-AddCustomer-1

#      [Documentation]  Add a new valid customer without email
   
#     ${resp}=  Consumer SignUp Notification   ${firstname}  ${lastname}    ${MobilenumHi}    ${countryCode}  
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     Append To File  ${EXECDIR}/data/TDD_Logs/consumernumbers.txt  ${MobilenumHi}${\n}

#     ${resp}=  Consumer Activation  ${MobilenumHi}  1
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${resp}=  Consumer Set Credential  ${MobilenumHi}  ${PASSWORD1}  1
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${resp}=  Consumer Login  ${MobilenumHi}  ${PASSWORD1}
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200

   

#      Should Be Equal As Strings    ${resp.status_code}    200
#      Set Test Variable  ${jdconID}   ${resp.json()['id']}
#      Set Test Variable  ${firstname}   ${resp.json()['firstName']}
#      Set Test Variable  ${lastname}   ${resp.json()['lastName']}

#      ${resp}=  Consumer Logout
#      Log   ${resp.json()}
#      Should Be Equal As Strings    ${resp.status_code}    200

#     ${domresp}=  Get BusinessDomainsConf
#     Log  ${domresp.json()}
#     Should Be Equal As Strings  ${domresp.status_code}  200
#     ${len}=  Get Length  ${domresp.json()}
#     ${domain_list}=  Create List
#     ${subdomain_list}=  Create List
#     FOR  ${domindex}  IN RANGE  ${len}
#         Set Test Variable  ${d}  ${domresp.json()[${domindex}]['domain']}    
#         Append To List  ${domain_list}    ${d} 
#         Set Test Variable  ${sd}  ${domresp.json()[${domindex}]['subDomains'][0]['subDomain']}
#         Append To List  ${subdomain_list}    ${sd} 
#     END
#     Log  ${domain_list}
#     Log  ${subdomain_list}
#     Set Suite Variable  ${domain_list}
#     Set Suite Variable  ${subdomain_list}
#     Set Test Variable   ${d1}   ${domain_list[0]}
#     Set Test Variable  ${sd1}  ${subdomain_list[0]}

#     ${highest_package}=  get_highest_license_pkg
    
#     ${resp}=  Account SignUp   simi  Dany  ${None}  ${d1}  ${sd1}  ${ConsMobilenum}    ${highest_package[0]}
#     Log  ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${resp}=  Account Activation  ${ConsMobilenum}  0
#     Log   ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${resp}=  Account Set Credential  ${ConsMobilenum}  ${NEW_PASSWORD12}  0
#     Should Be Equal As Strings    ${resp.status_code}    200

#     ${resp}=  Encrypted Provider Login  ${ConsMobilenum}  ${NEW_PASSWORD12}
#     Log  ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${ConsMobilenum}${\n}
#     Set Suite Variable  ${ConsMobilenum}
#     ${pid}=  get_acc_id  ${ConsMobilenum}
#     ${id}=  get_id  ${ConsMobilenum}
#     Set Suite Variable  ${id}
 
#     ${resp}=   Get Service
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=    Get Locations
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=   Get Appointment Settings
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Run Keyword If  ${resp.json()['enableAppt']}==${bool[0]}   Enable Appointment

#     clear_service   ${ConsMobilenum}
#     clear_location  ${ConsMobilenum}
#     clear_customer   ${ConsMobilenum}

#     ${resp}=   Get Service
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=    Get Locations
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200

   
#     ${resp}=   Get jaldeeIntegration Settings
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${resp1}=   Run Keyword If  ${resp.json()['walkinConsumerBecomesJdCons']}==${bool[0]}   Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${EMPTY}
#     Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.json()}
#     Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200
   
#     ${resp}=   Get jaldeeIntegration Settings
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     # Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[0]}
#     Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]} 

#     ${resp}=  Get Business Profile
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable  ${pid}  ${resp.json()['id']} 


    
#     ${DAY1}=  db.get_date_by_timezone  ${tz}
#     ${list}=  Create List  1  2  3  4  5  6  7
#     ${ph1}=  Evaluate  ${ConsMobilenum}+15566122
#     ${ph2}=  Evaluate  ${ConsMobilenum}+25566122
#     ${views}=  Random Element    ${Views}
#     ${name1}=  FakerLibrary.name
#     ${name2}=  FakerLibrary.name
#     ${name3}=  FakerLibrary.name
#     ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
#     ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
#     ${emails1}=  Emails  ${name3}  Email  ${EmailProConsreshma}  ${views}
#     ${bs}=  FakerLibrary.bs
#     ${city}=   get_place
#     ${latti}=  get_latitude
#     ${longi}=  get_longitude
#     ${companySuffix}=  FakerLibrary.companySuffix
#     ${postcode}=  FakerLibrary.postcode
#     ${address}=  get_address
#     ${parking}   Random Element   ${parkingType}
#     ${24hours}    Random Element    ${bool}
#     ${desc}=   FakerLibrary.sentence
#     ${url}=   FakerLibrary.url
#     ${sTime}=  add_timezone_time  ${tz}  0  15  
#     ${eTime}=  add_timezone_time  ${tz}  0  45  
#     ${resp}=  Update Business Profile with Schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}   ${address}   ${ph_nos1}   ${ph_nos2}   ${emails1}   ${EMPTY}
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200

#     ${resp}=  Get Business Profile
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=   Get Appointment Settings
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
#     Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]} 
#     ${fields}=   Get subDomain level Fields  ${d1}  ${sd1}
#     Log  ${fields.json()}
#     Should Be Equal As Strings    ${fields.status_code}   200

#     ${virtual_fields}=  get_Subdomainfields  ${fields.json()}

#     ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${sd1}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=  Get specializations Sub Domain  ${d1}  ${sd1}
#     Should Be Equal As Strings    ${resp.status_code}   200

#     ${spec}=  get_Specializations  ${resp.json()}
#     ${resp}=  Update Specialization  ${spec}
#     Log  ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}   200

   

#      ${dob}=  FakerLibrary.Date
#      ${gender}=  Random Element    ${Genderlist}
     
#      ${resp}=  AddCustomer without email   ${firstname}  ${lastname}  ${EMPTY}  ${gender}  ${dob}  ${MobilenumHi}  ${EMPTY}
#      Should Be Equal As Strings  ${resp.status_code}  200
#      Log  ${resp.json()}
#      Set Test Variable  ${cid}  ${resp.json()}
#      Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${MobilenumHi}${\n}
#      ${resp}=  GetCustomer ById  ${cid}
#      Should Be Equal As Strings  ${resp.status_code}  200
#      Log  ${resp.json()}
#      ${resp}=  GetCustomer    phoneNo-eq=${MobilenumHi}   status-eq=ACTIVE   
#      Log  ${resp.json()}
#      Should Be Equal As Strings  ${resp.status_code}  200

# JD-TC-AddCustomer- With email 2
#      [Documentation]  Add a new valid customer with email
#      ${resp}=  Encrypted Provider Login  ${ConsMobilenum}  ${NEW_PASSWORD12}
#      Should Be Equal As Strings  ${resp.status_code}  200
#      Set Test Variable  ${p_id}  ${resp.json()['id']}


#     ${resp}=   Get jaldeeIntegration Settings
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     IF  '${resp.json()['walkinConsumerBecomesJdCons']}'=='${bool[0]}' and '${resp.json()['onlinePresence']}'=='${bool[0]}'
#         ${resp1}=   Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[1]}  ${boolean[0]}
#         Should Be Equal As Strings  ${resp1.status_code}  200
#     ELSE IF    '${resp.json()['walkinConsumerBecomesJdCons']}'=='${bool[0]}' and '${resp.json()['onlinePresence']}'=='${bool[1]}'
#         ${resp1}=   Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${boolean[0]}
#         Should Be Equal As Strings  ${resp1.status_code}  200
#     END

#     ${resp}=   Get jaldeeIntegration Settings
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}

#      ${firstname1}=  FakerLibrary.first_name
#      Set Suite Variable  ${firstname1}
#      ${lastname1}=  FakerLibrary.last_name
#      Set Suite Variable  ${lastname1}
#      ${dob1}=  FakerLibrary.Date
#      Set Suite Variable  ${dob1}
#      ${gender1}=  Random Element    ${Genderlist}
#      Set Suite Variable  ${gender1}
#     #  ${ph2}=  Evaluate  ${PUSERNAME230}+86233
#     #  Set Suite Variable  ${ph2}
#     #  Set Suite Variable  ${email2}  ${firstname1}${ph2}${C_Email}.${test_mail}
#      ${resp}=  AddCustomer with email   Raigan   AR   ${EMPTY}  ${conEmail1simi}  ${gender1}  ${dob1}  ${MobilenumHi}  ${EMPTY}
#      Should Be Equal As Strings  ${resp.status_code}  200
#      Log  ${resp.json()}
#      Set Test Variable  ${cid1}  ${resp.json()}
#      Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${MobilenumHi}${\n}
#      ${resp}=  GetCustomer    phoneNo-eq=${MobilenumHi}    status-eq=ACTIVE  
#      Log  ${resp.json()}
#      Should Be Equal As Strings  ${resp.status_code}  200
 
    

# *** Comments ***
# JD-TC-CreateUser-1
# #   create user ok

#     [Documentation]  Create a user by branch login
#     ${iscorp_subdomains}=  get_iscorp_subdomains  1
#     Log  ${iscorp_subdomains}
#     Set Suite Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
#     Set Suite Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
#     # Set Suite Variable  ${sub_domain_id}   ${iscorp_subdomains[0]['subdomainId']}
#     # Set Suite Variable  ${sub_domain_id}   ${iscorp_subdomains[0]['subdomainId']}
#     ${firstname_A}=  FakerLibrary.first_name
#     Set Suite Variable  ${firstname_A}
#     ${lastname_A}=  FakerLibrary.last_name
#     Set Suite Variable  ${lastname_A}
#     # ${PUSERNAME_E}=  Evaluate  ${PUSERNAME}+55045300
#     ${highest_package}=  get_highest_license_pkg
#     ${resp}=  Account SignUp   simi  Dany  ${None}  ${domains}  ${sub_domains}  ${ConsMobilenum}    ${highest_package[0]}
#     Log  ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${resp}=  Account Activation  ${ConsMobilenum}  0
#     Log   ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${resp}=  Account Set Credential  ${ConsMobilenum}  ${NEW_PASSWORD12}  0
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${resp}=  Encrypted Provider Login  ${ConsMobilenum}  ${NEW_PASSWORD12}
#     Log  ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${ConsMobilenum}${\n}
#     Set Suite Variable  ${ConsMobilenum}
#     ${id}=  get_id  ${ConsMobilenum}
#     Set Suite Variable  ${id}
#     ${bs}=  FakerLibrary.bs
#     Set Suite Variable  ${bs}
#     ${resp}=  Toggle Department Enable
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     sleep  2s
#     ${resp}=  Get Departments
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Suite Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}
#     # ${PUSERNAME_U1}=  Evaluate  ${PUSERNAME}+336645
#     clear_users  ${MobilenumHi122}
#     # Set Suite Variable  ${MobilenumHi122}
#     ${firstname}=  FakerLibrary.name
#     Set Suite Variable  ${firstname}
#     ${lastname}=  FakerLibrary.last_name
#     Set Suite Variable  ${lastname}
#     ${dob}=  FakerLibrary.Date
#     Set Suite Variable  ${dob}
#     # ${pin}=  get_pincode
#      # Set Suite Variable  ${pin}
#      # ${resp}=  Get LocationsByPincode     ${pin}
#      FOR    ${i}    IN RANGE    3
#         ${pin}=  get_pincode
#         ${kwstatus}  ${resp} =  Run Keyword And Ignore Error  Get LocationsByPincode  ${pin}
#         IF    '${kwstatus}' == 'FAIL'
#                 Continue For Loop
#         ELSE IF    '${kwstatus}' == 'PASS'
#                 Exit For Loop
#         END
#      END
#      Should Be Equal As Strings    ${resp.status_code}    200 
#      Set Suite Variable  ${pin}
#     Log  ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     Set Suite Variable  ${city}   ${resp.json()[0]['PostOffice'][0]['District']}   
#     Set Suite Variable  ${state}  ${resp.json()[0]['PostOffice'][0]['State']}      
#     Set Suite Variable  ${pin}    ${resp.json()[0]['PostOffice'][0]['Pincode']}    

#     ${whpnum}=  Evaluate  ${PUSERNAME}+346245
#     ${tlgnum}=  Evaluate  ${PUSERNAME}+346345

#     ${resp}=  Create User   Hisham  Mohammad  ${dob}  ${Genderlist[0]}  ${Emailhisham}   ${userType[2]}  ${pin}  ${countryCodes[1]}  ${MobilenumHi}  ${dep_id}  ${EMPTY}  ${bool[1]}  ${countryCodes[1]}  ${whpnum}  ${countryCodes[1]}  ${tlgnum}
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Suite Variable  ${u_id}  ${resp.json()}

#     ${iscorp_subdomains}=  get_iscorp_subdomains  1
#     Log  ${iscorp_subdomains}
#     ${dlen}=  Get Length  ${iscorp_subdomains}
#     FOR  ${pos}  IN RANGE  ${dlen}  
#         IF  '${iscorp_subdomains[${pos}]['subdomains']}' == '${sub_domains}'
#             Set Suite Variable  ${sub_domain_id}   ${iscorp_subdomains[${pos}]['subdomainId']}
#             Set Suite Variable  ${userSubDomain}  ${iscorp_subdomains[${pos}]['userSubDomain']}
#             Exit For Loop
#         ELSE
#             Continue For Loop
#         END
#     END

#     ${resp}=  Get User By Id  ${u_id}
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
# *** Comments ***
#     Set Suite Variable  ${sub_domain_id}  ${resp.json()['subdomain']}
#     Verify Response  ${resp}  id=${u_id}  firstName=${firstname}  lastName=${lastname}   mobileNo=${PUSERNAME_U1}  dob=${dob}  gender=${Genderlist[0]}  userType=${userType[2]}  status=ACTIVE  email=${P_Email}${PUSERNAME_U1}.${test_mail}  city=${city}  state=${state}  pincode=${pin}   deptId=0  subdomain=${sub_domain_id}
#     Should Be Equal As Strings  ${resp.json()['whatsAppNum']['number']}           ${whpnum} 
#     Should Be Equal As Strings  ${resp.json()['whatsAppNum']['countryCode']}      ${countryCodes[1]}
#     Should Be Equal As Strings  ${resp.json()['telegramNum']['number']}           ${tlgnum} 
#     Should Be Equal As Strings  ${resp.json()['telegramNum']['countryCode']}      ${countryCodes[1]}
       
#     ${resp}=  Get User Count
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Should Be Equal As Strings  ${resp.json()}  2
#     ${resp}=  Get User
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${len}=  Get Length  ${resp.json()}
#     # Should Be Equal As Integers  ${len}  3
#     FOR  ${i}  IN RANGE   ${len}
#         Run Keyword IF  '${resp.json()[${i}]['id']}' == '${u_id}'  
#         ...    Run Keywords 
#         ...    Should Be Equal As Strings       ${resp.json()[${i}]['firstName']}                       ${firstname}       
#         ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['lastName']}                        ${lastname}       
#         ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['mobileNo']}                        ${PUSERNAME_U1}      
#         ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['dob']}                             ${dob}      
#         ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['gender']}                          ${Genderlist[0]}      
#         ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['userType']}                        ${userType[2]}     
#         ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['status']}                          ACTIVE    
#         ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['email']}                           ${P_Email}${PUSERNAME_U1}.${test_mail}  
#         ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['city']}                            ${city}  
#         ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['state']}                           ${state}
#         ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['deptId']}                          0   
#         ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['subdomain']}                       0
#         ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['admin']}                           ${bool[1]} 
#         ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['pincode']}                         ${pin} 
#         ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['whatsAppNum']['number']}           ${whpnum} 
#         ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['whatsAppNum']['countryCode']}      ${countryCodes[1]}
#         ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['telegramNum']['number']}           ${tlgnum} 
#         ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['telegramNum']['countryCode']}      ${countryCodes[1]}
       

#         ...    ELSE IF     '${resp.json()[${i}]['id']}' == '${id}'   
#         ...    Run Keywords
#         ...    Should Be Equal As Strings       ${resp.json()[${i}]['firstName']}                       ${firstname_A}       
#         ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['lastName']}                        ${lastname_A} 
#         ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['userType']}                        ${userType[0]}     
#         ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['status']}                          ACTIVE    
#         ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['mobileNo']}                        ${PUSERNAME_E}
#         ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['deptId']}                          ${dep_id}    
#         ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['subdomain']}                       1
#         ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['admin']}                           ${bool[1]} 
      
#     END

# # JD-TC-Update CustomerDetails-4
# # 	[Documentation]  Update a valid customer here add a new consumer number(new keyword)
# #     ${resp}=  Encrypted Provider Login  ${ConsMobilenum}  ${PASSWORD2}
# #     Should Be Equal As Strings  ${resp.status_code}  200
# #     Set Test Variable  ${p_id}  ${resp.json()['id']}
# #     # ${firstname}=  FakerLibrary.first_name
# #     # ${lastname}=  FakerLibrary.last_name
# #     # ${ph}=  Evaluate  ${PUSERNAME230}+71018
# #     ${resp}=  AddCustomer  ${ph}  firstName=${firstname}   lastName=${lastname} 
# #     Log   ${resp.json()}
# #     Should Be Equal As Strings  ${resp.status_code}  200
# #     Set Test Variable  ${cid}  ${resp.json()}
# #     Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${ph}${\n}
# #     ${firstname1}=  FakerLibrary.first_name
# #     ${lastname1}=  FakerLibrary.last_name
# #     ${ph1}=  Evaluate  ${PUSERNAME230}+71019
# #     Set Test Variable  ${ph1}
# #     ${resp}=  Update Customer Details  ${cid}  phoneNo=${ph1}  countryCode=91  firstName=${firstname1}  lastName=${lastname1}  
# #     Log  ${resp.json()}
# #     Should Be Equal As Strings  ${resp.status_code}  200
# #     Set Test Variable  ${ncid}  ${resp.json()}
# #     Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${ph1}${\n}
# #     ${resp}=  GetCustomer    phoneNo-eq=${ph1}
# #     Should Be Equal As Strings  ${resp.status_code}  200
# #     Log  ${resp.json()}
# #     Should Be Equal As Strings  ${resp.status_code}  200 
# #     Verify Response List  ${resp}  0  firstName=${firstname1}  lastName=${lastname1}  phoneNo=${ph1}   email_verified=${bool[0]}   phone_verified=${bool[0]}  id=${cid}   favourite=${bool[0]}
   


# # JD-TC-Provider_Signup -2
# #     [Documentation]    Create a provider with all valid attributes(email notification)
# #     ${domresp}=  Get BusinessDomainsConf
# #     Log  ${domresp.json()}
# #     Should Be Equal As Strings  ${domresp.status_code}  200
# #     ${len}=  Get Length  ${domresp.json()}
# #     ${domain_list}=  Create List
# #     ${subdomain_list}=  Create List
# #     FOR  ${domindex}  IN RANGE  ${len}
# #         Set Test Variable  ${d}  ${domresp.json()[${domindex}]['domain']}    
# #         Append To List  ${domain_list}    ${d} 
# #         Set Test Variable  ${sd}  ${domresp.json()[${domindex}]['subDomains'][0]['subDomain']}
# #         Append To List  ${subdomain_list}    ${sd} 
# #     END
# #     Log  ${domain_list}
# #     Log  ${subdomain_list}
# #     Set Suite Variable  ${domain_list}
# #     Set Suite Variable  ${subdomain_list}
# #     Set Test Variable  ${d1}  ${domain_list[0]}
# #     Set Test Variable  ${sd1}  ${subdomain_list[0]}
# #     # ${ph}=  Evaluate  ${PUSERNAME}+5666554
# #     # Set Suite Variable  ${ph}
# #     # ${firstname}=  FakerLibrary.first_name
# #     # ${lastname}=  FakerLibrary.last_name
# #     # ${resp}=  Account SignUp Notification  ${firstname}  ${lastname}    ${internatMobNum}   ${internatcountryCode}    ${d1}   ${sd1}   1  email=${consEmail}   
# #     ${resp}=  Account SignUp Notification  ${firstname}  ${lastname}  ${conEmail1simi}  ${d1}  ${sd1}  ${internatMobNum}   1   ${internatcountryCode}
# #     Should Be Equal As Strings    ${resp.status_code}    200
# #     Log  ${resp.content}
# #     ${resp}=  Account Activation  ${conEmail1simi}  0
# #     Should Be Equal As Strings    ${resp.status_code}    200 
# #     Log  ${resp.content}  
# #     ${resp}=  Account Set Credential Notification   ${conEmail1simi}  ${PASSWORD2}  0   ${internatcountryCode}
# #     Should Be Equal As Strings    ${resp.status_code}    200
# #     Log  ${resp.content}
# #     ${resp}=  Encrypted Provider Login Notification   ${conEmail1simi}  ${PASSWORD2}  ${internatcountryCode}
# #     Should Be Equal As Strings    ${resp.status_code}    200
# #     Log  ${resp.content}
# #     Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${conEmail1simi}${\n}

# JD-TC-Provider_Signup -3
#     [Documentation]    Create a provider with all valid attributes(email notification)
#     ${domresp}=  Get BusinessDomainsConf
#     Log  ${domresp.json()}
#     Should Be Equal As Strings  ${domresp.status_code}  200
#     ${len}=  Get Length  ${domresp.json()}
#     ${domain_list}=  Create List
#     ${subdomain_list}=  Create List
#     FOR  ${domindex}  IN RANGE  ${len}
#         Set Test Variable  ${d}  ${domresp.json()[${domindex}]['domain']}    
#         Append To List  ${domain_list}    ${d} 
#         Set Test Variable  ${sd}  ${domresp.json()[${domindex}]['subDomains'][0]['subDomain']}
#         Append To List  ${subdomain_list}    ${sd} 
#     END
#     Log  ${domain_list}
#     Log  ${subdomain_list}
#     Set Suite Variable  ${domain_list}
#     Set Suite Variable  ${subdomain_list}
#     Set Test Variable  ${d1}  ${domain_list[0]}
#     Set Test Variable  ${sd1}  ${subdomain_list[0]}
#     # ${ph}=  Evaluate  ${PUSERNAME}+5666554
#     # Set Suite Variable  ${ph}
#     # ${firstname}=  FakerLibrary.first_name
#     # ${lastname}=  FakerLibrary.last_name
#     # ${resp}=  Account SignUp Notification  ${firstname}  ${lastname}    ${internatMobNum}   ${internatcountryCode}    ${d1}   ${sd1}   1  email=${consEmail}   
#     ${resp}=  Account SignUp Notification  ${firstname}  ${lastname}  ${conEmail1simi}  ${d1}  ${sd1}  ${ConsMobilenum}   1   ${countryCode}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     Log  ${resp.content}
#     ${resp}=  Account Activation  ${conEmail1simi}  0
#     Should Be Equal As Strings    ${resp.status_code}    200 
#     Log  ${resp.content}  
#     ${resp}=  Account Set Credential Notification   ${conEmail1simi}  ${PASSWORD2}  0   ${countryCode}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     Log  ${resp.content}
#     ${resp}=  Encrypted Provider Login Notification   ${conEmail1simi}  ${PASSWORD2}  ${countryCode}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     Log  ${resp.content}
#     Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${conEmail1simi}${\n}

    

# *** Comments ***

# JD-TC-Provider_Signup -3
#     [Documentation]    Create a provider with all valid attributes(email notification)
#     ${domresp}=  Get BusinessDomainsConf
#     Log  ${domresp.json()}
#     Should Be Equal As Strings  ${domresp.status_code}  200
#     ${len}=  Get Length  ${domresp.json()}
#     ${domain_list}=  Create List
#     ${subdomain_list}=  Create List
#     FOR  ${domindex}  IN RANGE  ${len}
#         Set Test Variable  ${d}  ${domresp.json()[${domindex}]['domain']}    
#         Append To List  ${domain_list}    ${d} 
#         Set Test Variable  ${sd}  ${domresp.json()[${domindex}]['subDomains'][0]['subDomain']}
#         Append To List  ${subdomain_list}    ${sd} 
#     END
#     Log  ${domain_list}
#     Log  ${subdomain_list}
#     Set Suite Variable  ${domain_list}
#     Set Suite Variable  ${subdomain_list}
#     Set Test Variable  ${d1}  ${domain_list[0]}
#     Set Test Variable  ${sd1}  ${subdomain_list[0]}
#     # ${ph}=  Evaluate  ${PUSERNAME}+5666554
#     # Set Suite Variable  ${ph}
#     # ${firstname}=  FakerLibrary.first_name
#     # ${lastname}=  FakerLibrary.last_name
#     # ${resp}=  Account SignUp Notification  ${firstname}  ${lastname}    ${internatMobNum}   ${internatcountryCode}    ${d1}   ${sd1}   1  email=${consEmail}   
#     ${resp}=  Account SignUp Notification  ${firstname}  ${lastname}  ${conEmail1simi}  ${d1}  ${sd1}  ${ConsMobilenum}   1   ${countryCode}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     Log  ${resp.content}
#     ${resp}=  Account Activation  ${conEmail1simi}  0
#     Should Be Equal As Strings    ${resp.status_code}    200 
#     Log  ${resp.content}  
#     ${resp}=  Account Set Credential Notification   ${conEmail1simi}  ${PASSWORD2}  0   ${countryCode}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     Log  ${resp.content}
#     ${resp}=  Encrypted Provider Login Notification   ${conEmail1simi}  ${PASSWORD2}  ${countryCode}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     Log  ${resp.content}
#     Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${conEmail1simi}${\n}

# JD-TC-providerConsumerSignup-1
#     [Documentation]    Provider Consumer Signup with phonne num
#     ${resp}=   Encrypted Provider Login  ${ConsMobilenum}  ${PASSWORD2} 
#     Log  ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}   200
#     ${accountId}=    get_acc_id       ${ConsMobilenum}

#     ${resp}=   Get jaldeeIntegration Settings
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     #  ${resp}=  Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[0]}  ${boolean[0]}
#     # Log   ${resp.json()}
#     # Should Be Equal As Strings  ${resp.status_code}  200
#     # ${resp}=  Get jaldeeIntegration Settings
#     # Log   ${resp.json()}
#     # Should Be Equal As Strings  ${resp.status_code}  200
#     # Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}


#     # ${firstName}=  FakerLibrary.name
#     # Set Suite Variable    ${firstName}
#     # ${lastName}=  FakerLibrary.last_name
#     # Set Suite Variable    ${lastName}
#     # ${primaryMobileNo}    Generate random string    10    123456789
#     # ${primaryMobileNo}    Convert To Integer  ${primaryMobileNo}
#     # Set Suite Variable    ${primaryMobileNo}
#     # ${email}=    FakerLibrary.Email
#     # Set Suite Variable    ${email}

#     ${resp}=    Send Otp For Login    ${MobilenumHi}    ${accountId}
#     Log   ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}   200

#     ${resp}=    Verify Otp For Login   ${MobilenumHi}   ${OtpPurpose['Authentication']}
#     Log   ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}   200
#     Set Suite Variable  ${token}  ${resp.json()['token']}

#     ${resp}=    Customer Logout 
#     Log   ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}   200

#     ${resp}=    ProviderConsumer SignUp    ${firstName}  ${lastName}  ${consEmail}    ${MobilenumHi}     ${accountId}
#     Log  ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}   200

#     ${resp}=   Encrypted Provider Login  ${ConsMobilenum}  ${PASSWORD2} 
#     Log  ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}   200

#     ${resp}=   Get jaldeeIntegration Settings
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     # Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[0]}

# JD-TC-providerConsumerSignup-3
#     [Documentation]    Provider Consumer Signup with email
#     ${resp}=   Encrypted Provider Login  ${ConsMobilenum}  ${PASSWORD2} 
#     Log  ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}   200
#     ${accountId}=    get_acc_id       ${ConsMobilenum}

#     ${resp}=   Get jaldeeIntegration Settings
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     #  ${resp}=  Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[0]}  ${boolean[0]}
#     # Log   ${resp.json()}
#     # Should Be Equal As Strings  ${resp.status_code}  200
#     # ${resp}=  Get jaldeeIntegration Settings
#     # Log   ${resp.json()}
#     # Should Be Equal As Strings  ${resp.status_code}  200
#     # Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}


#     # ${firstName}=  FakerLibrary.name
#     # Set Suite Variable    ${firstName}
#     # ${lastName}=  FakerLibrary.last_name
#     # Set Suite Variable    ${lastName}
#     # ${primaryMobileNo}    Generate random string    10    123456789
#     # ${primaryMobileNo}    Convert To Integer  ${primaryMobileNo}
#     # Set Suite Variable    ${primaryMobileNo}
#     # ${email}=    FakerLibrary.Email
#     # Set Suite Variable    ${email}

#     ${resp}=    Send Otp For Login    ${MobilenumHi}    ${accountId}
#     Log   ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}   200

#     ${resp}=    Verify Otp For Login   ${MobilenumHi}   ${OtpPurpose['Authentication']}
#     Log   ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}   200
#     Set Suite Variable  ${token}  ${resp.json()['token']}

#     ${resp}=    Customer Logout 
#     Log   ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}   200

#     ${resp}=    ProviderConsumer SignUp    ${firstName}  ${lastName}  ${EmailProConsreshma}    ${MobilenumHi}     ${accountId}
#     Log  ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}   200

#     ${resp}=   Encrypted Provider Login  ${ConsMobilenum}  ${PASSWORD2} 
#     Log  ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}   200

#     ${resp}=   Get jaldeeIntegration Settings
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     # Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[0]}

# JD-TC-ResetPassword Consumer-1
#     [Documentation]    Reset consumer login password 
#     ${resp}=  Send Reset Email   ${consEmail}
#     Log   ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     @{resp}=  Reset Password  ${consEmail}  ${NewPASSWORD}  3
#     Should Be Equal As Strings  ${resp[0].status_code}  200
#     Should Be Equal As Strings  ${resp[1].status_code}  200
#     ${resp}=  Consumer Login Notification   ${ConsMobilenum}   ${NewPASSWORD}   ${countryCode}
#     # ${resp}=  Consumer Login  ${consEmail}  ${NewPASSWORD}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200

# JD-TC-ProviderChangePassword-1
#     [Documentation]    Provider Change password

#     ${resp}=  Encrypted Provider Login  ${ConsMobilenum}  ${PASSWORD2}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${resp}=  Provider Change Password  ${PASSWORD2}  ${NEW_PASSWORD12}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${resp}=  Encrypted Provider Login  ${ConsMobilenum}  ${NEW_PASSWORD12}
#     Should Be Equal As Strings    ${resp.status_code}    200

# JD-TC-ProviderChangePassword-2
#     [Documentation]    Provider Change password  with email

#     ${resp}=  Encrypted Provider Login  ${consEmail}  ${PASSWORD2}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${resp}=  Provider Change Password  ${PASSWORD2}  ${NEW_PASSWORD12}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${resp}=  Encrypted Provider Login  ${consEmail}  ${NEW_PASSWORD12}
#     Should Be Equal As Strings    ${resp.status_code}    200



# *** Comments ***
# JD-TC-UpdateBusinessProfile-1
#     [Documentation]  Update  business profile for a valid provider without schedule
#     ${resp}=  Encrypted Provider Login  ${PUSERNAME2}  ${PASSWORD}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Suite Variable  ${d}  ${resp.json()['sector']}
#     Set Suite Variable  ${sd}  ${resp.json()['subSector']}
#     ${DAY1}=  db.get_date_by_timezone  ${tz}
#     Set Suite Variable  ${DAY1}  ${DAY1}
#     ${list}=  Create List  1  2  3  4  5  6  7
#     Set Suite Variable  ${list}  ${list}
#     ${bs}=  FakerLibrary.bs
#     ${city}=   get_place
#     ${latti}=  get_latitude
#     ${longi}=  get_longitude
#     ${companySuffix}=  FakerLibrary.companySuffix
#     ${postcode}=  FakerLibrary.postcode
#     ${address}=  get_address
#     ${ph1}=  Evaluate  ${PUSERNAME}+11001
#     Set Suite Variable  ${ph1}
#     ${ph2}=  Evaluate  ${PUSERNAME}+11002
#     Set Suite Variable  ${ph2}
#     ${views}=  Evaluate  random.choice($Views)  random
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
#     ${emails1}=  Emails  ${name3}  Email  ${P_Email}${bs}.${test_mail}  ${views}

#     ${resp}=  Get Business Profile
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable  ${createdDAY}  ${resp.json()['createdDate']}

#     ${resp}=  Get Locations
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable  ${lid}  ${resp.json()[0]['id']}
#     ${resp}=  Update Business Profile without schedule   ${bs}  ${bs}Desc   ${companySuffix}  ${city}  ${longi}  ${latti}  www.${bs}.com  free  True  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}  ${lid}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${resp}=  Get Business Profile
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Verify Response  ${resp}  businessName=${bs}  businessDesc=${bs}Desc  shortName=${companySuffix}  status=ACTIVE  createdDate=${createdDAY}  updatedDate=${DAY1}
#     Should Be Equal As Strings  ${resp.json()['serviceSector']['domain']}  ${d}
#     Should Be Equal As Strings  ${resp.json()['serviceSubSector']['subDomain']}  ${sd}
#     Should Be Equal As Strings  ${resp.json()['emails'][0]['label']}  ${name3}
#     Should Be Equal As Strings  ${resp.json()['emails'][0]['instance']}  ${P_Email}${bs}.${test_mail}
#     Should Be Equal As Strings  ${resp.json()['phoneNumbers'][0]['label']}  ${name1}
#     Should Be Equal As Strings  ${resp.json()['phoneNumbers'][0]['instance']}  ${ph1}
#     Should Be Equal As Strings  ${resp.json()['phoneNumbers'][1]['label']}  ${name2}
#     Should Be Equal As Strings  ${resp.json()['phoneNumbers'][1]['instance']}  ${ph2}
#     Should Be Equal As Strings  ${resp.json()['baseLocation']['place']}  ${city}
#     Should Be Equal As Strings  ${resp.json()['baseLocation']['address']}   ${address}
#     Should Be Equal As Strings  ${resp.json()['baseLocation']['pinCode']}  ${postcode}
#     Should Be Equal As Strings  ${resp.json()['baseLocation']['longitude']}  ${longi}
#     Should Be Equal As Strings  ${resp.json()['baseLocation']['lattitude']}  ${latti}
#     Should Be Equal As Strings  ${resp.json()['baseLocation']['googleMapUrl']}  www.${bs}.com
#     Should Be Equal As Strings  ${resp.json()['baseLocation']['parkingType']}  free
#     Should Be Equal As Strings  ${resp.json()['baseLocation']['open24hours']}  True

# JD-TC-Consumer Signup-1
#     [Documentation]   Create consumer via qrcode with all valid attributes 


#     ${iscorp_subdomains}=  get_iscorp_subdomains  1
#     Log  ${iscorp_subdomains}
#     Set Suite Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
#     Set Suite Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
#     # Set Suite Variable  ${sub_domain_id}   ${iscorp_subdomains[0]['subdomainId']}
#     # Set Suite Variable  ${sub_domain_id}   ${iscorp_subdomains[0]['subdomainId']}
#     ${firstname_A}=  FakerLibrary.first_name
#     Set Suite Variable  ${firstname_A}
#     ${lastname_A}=  FakerLibrary.last_name
#     Set Suite Variable  ${lastname_A}
#     # ${PUSERNAME_E}=  Evaluate  ${PUSERNAME}+55045300
#     ${highest_package}=  get_highest_license_pkg
#     ${resp}=  Account SignUp   simi  Dany  ${None}  ${domains}  ${sub_domains}  ${ConsMobilenum}    ${highest_package[0]}
#     Log  ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${resp}=  Account Activation  ${ConsMobilenum}  0
#     Log   ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${resp}=  Account Set Credential  ${ConsMobilenum}  ${NEW_PASSWORD12}  0
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${resp}=  Encrypted Provider Login  ${ConsMobilenum}  ${NEW_PASSWORD12}
#     Log  ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${ConsMobilenum}${\n}
#     Set Suite Variable  ${ConsMobilenum}
#     ${id}=  get_id  ${ConsMobilenum}
#     Set Suite Variable  ${id}
#     ${bs}=  FakerLibrary.bs
#     Set Suite Variable  ${bs}
#     ${resp}=  Toggle Department Enable
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     sleep  2s
#     clear_customer   ${ConsMobilenum}
#     ${resp}=  Encrypted Provider Login  ${ConsMobilenum}  ${PASSWORD}
#     Log  ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200

#     ${pid}=  get_acc_id  ${ConsMobilenum}
  
#     # ${CUSERPH0}=  Evaluate  ${CUSERPH}+100200201
#     # Set Suite Variable   ${CUSERPH0}
#     # Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${CUSERPH0}${\n}
#     # ${CUSERPH_SECOND}=  Evaluate  ${CUSERPH0}+1000
#     # ${firstname}=  FakerLibrary.first_name
#     # ${lastname}=  FakerLibrary.last_name
#     # ${email}=   FakerLibrary.email
#     ${resp}=  Consumer SignUp Via QRcode   Muhammed   HIsham   ${MobilenumHi}   ${countryCodes[0]}  ${pid}  ${Emailhisham}
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${resp}=  Consumer Activation  ${email}  1
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${resp}=  Consumer Set Credential  ${email}  ${PASSWORD}  1
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${resp}=  Consumer Login  ${CUSERPH0}  ${PASSWORD}
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200

#     Append To File  ${EXECDIR}/data/TDD_Logs/consumernumbers.txt  ${CUSERPH0}${\n}

#     ${resp}=  Encrypted Provider Login  ${PUSERNAME152}  ${PASSWORD}
#     Log  ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200

#     ${resp}=  GetCustomer  
#     Log   ${resp.json()}
#     Should Be Equal As Strings      ${resp.status_code}  200
#     Verify Response List  ${resp}  0  firstName=${firstname}  lastName=${lastname}  phoneNo=${CUSERPH0} 


# JD-TC-Take Appointment By Consumer-1

#     [Documentation]  Consumer takes appointment for a valid Provider
  
#     ${multilocdoms}=  get_mutilocation_domains
#     Log  ${multilocdoms}
#     Set Suite Variable  ${dom}  ${multilocdoms[0]['domain']}
#     Set Suite Variable  ${sub_dom}  ${multilocdoms[0]['subdomains'][0]}


#     ${iscorp_subdomains}=  get_iscorp_subdomains  1
#     Log  ${iscorp_subdomains}
#     Set Suite Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
#     Set Suite Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
#     # Set Suite Variable  ${sub_domain_id}   ${iscorp_subdomains[0]['subdomainId']}
#     # Set Suite Variable  ${sub_domain_id}   ${iscorp_subdomains[0]['subdomainId']}
#     ${firstname_A}=  FakerLibrary.first_name
#     Set Suite Variable  ${firstname_A}
#     ${lastname_A}=  FakerLibrary.last_name
#     Set Suite Variable  ${lastname_A}
#     # ${PUSERNAME_E}=  Evaluate  ${PUSERNAME}+55045300
#     ${highest_package}=  get_highest_license_pkg
#     ${resp}=  Account SignUp   simi  Dany  ${None}  ${domains}  ${sub_domains}  ${ConsMobilenum}    ${highest_package[0]}
#     Log  ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${resp}=  Account Activation  ${ConsMobilenum}  0
#     Log   ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${resp}=  Account Set Credential  ${ConsMobilenum}  ${NEW_PASSWORD12}  0
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${resp}=  Encrypted Provider Login  ${ConsMobilenum}  ${NEW_PASSWORD12}
#     Log  ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${ConsMobilenum}${\n}
#     Set Suite Variable  ${ConsMobilenum}
#     ${pid}=  get_acc_id  ${ConsMobilenum}
#     ${id}=  get_id  ${ConsMobilenum}
#     Set Suite Variable  ${id}
#     ${bs}=  FakerLibrary.bs
#     Set Suite Variable  ${bs}
#    ${resp}=  View Waitlist Settings
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${resp}=  Run Keyword If  ${resp.json()['filterByDept']}==${bool[0]}   Toggle Department Enable
#     Run Keyword If  '${resp}' != '${None}'   Log  ${resp.content}
#     Run Keyword If  '${resp}' != '${None}'   Should Be Equal As Strings  ${resp.status_code}  200
    
#     sleep  2s
#     ${dep_name1}=  FakerLibrary.bs
#     ${dep_code1}=   Random Int  min=100   max=999
#     ${dep_desc1}=   FakerLibrary.word  
#     ${resp}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1} 
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Suite Variable  ${dep_id}  ${resp.json()}
    
#     ${resp}=  Get Departments
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Suite Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}

    
    
#     ${DAY1}=  db.get_date_by_timezone  ${tz}
#     ${list}=  Create List  1  2  3  4  5  6  7
#     ${ph1}=  Evaluate  ${ConsMobilenum}+15566122
#     ${ph2}=  Evaluate  ${ConsMobilenum}+25566122
#     ${views}=  Random Element    ${Views}
#     ${name1}=  FakerLibrary.name
#     ${name2}=  FakerLibrary.name
#     ${name3}=  FakerLibrary.name
#     ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
#     ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
#     ${emails1}=  Emails  ${name3}  Email  ${EmailProConsreshma}  ${views}
#     ${bs}=  FakerLibrary.bs
#     ${city}=   get_place
#     ${latti}=  get_latitude
#     ${longi}=  get_longitude
#     ${companySuffix}=  FakerLibrary.companySuffix
#     ${postcode}=  FakerLibrary.postcode
#     ${address}=  get_address
#     ${parking}   Random Element   ${parkingType}
#     ${24hours}    Random Element    ${bool}
#     ${desc}=   FakerLibrary.sentence
#     ${url}=   FakerLibrary.url
#     ${sTime}=  add_timezone_time  ${tz}  0  15  
#     ${eTime}=  add_timezone_time  ${tz}  0  45  
#     ${resp}=  Update Business Profile with Schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}   ${address}   ${ph_nos1}   ${ph_nos2}   ${emails1}   ${EMPTY}
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200

#     ${resp}=  Get Business Profile
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${fields}=   Get subDomain level Fields  ${dom}  ${sub_dom}
#     Log  ${fields.json()}
#     Should Be Equal As Strings    ${fields.status_code}   200

#     ${virtual_fields}=  get_Subdomainfields  ${fields.json()}

#     # ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${sub_dom}
#     # Log  ${resp.content}
#     # Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=  Get specializations Sub Domain  ${dom}  ${sub_dom}
#     Should Be Equal As Strings    ${resp.status_code}   200

#     ${spec}=  get_Specializations  ${resp.json()}
#     ${resp}=  Update Specialization  ${spec}
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}   200

#     ${resp}=  Enable Appointment
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     sleep   01s
    
#     ${resp}=  Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[0]}  ${boolean[0]}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${resp}=  Get jaldeeIntegration Settings
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}

#     ${resp}=   Get Appointment Settings
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
#     Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}

#     clear_service   ${ConsMobilenum}
#     clear_location  ${ConsMobilenum}    
#     ${resp}=   Get Service
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=  Get Departments
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Suite Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}

#     ${resp}=    Get Locations
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${pid}=  get_acc_id  ${ConsMobilenum}
#     Set Suite Variable   ${pid}
#     ${DAY1}=  db.get_date_by_timezone  ${tz}
#     Set Suite Variable   ${DAY1}
#     ${DAY2}=  db.add_timezone_date  ${tz}  10        
#     ${list}=  Create List  1  2  3  4  5  6  7
#     ${sTime1}=  add_timezone_time  ${tz}  0  15  
#     ${delta}=  FakerLibrary.Random Int  min=10  max=60
#     ${eTime1}=  add_two   ${sTime1}  ${delta}
#     ${lid}=  Create Sample Location
#     Set Suite Variable   ${lid}
#     clear_appt_schedule   ${ConsMobilenum}
#     ${SERVICE1}=   FakerLibrary.name
 
 
   

#     ${ser_durtn}=   Random Int   min=2   max=10
#     ${ser_amount}=   Random Int   min=200   max=500
#     ${ser_amount}=  Convert To Number  ${ser_amount}  1
#     Set Suite Variable    ${ser_amount} 
#     ${min_pre}=   Random Int   min=10   max=50
#     ${min_pre}=  Convert To Number  ${min_pre}  1
#     Set Suite Variable    ${min_pre} 
#     ${notify}    Random Element     ['True','False']
#     ${notifytype}    Random Element     ['none','pushMsg','email']
#     ${SERVICE1}=   FakerLibrary.name
#     ${description}=  FakerLibrary.sentence
#     ${resp}=  Create Service  ${SERVICE1}  ${description}   ${ser_durtn}  ${status[0]}  ${btype}  ${notify}   ${notifytype}  ${min_pre}  ${ser_amount}  ${bool[1]}  ${bool[1]}
#     Should Be Equal As Strings  ${resp.status_code}  200 
#     Set Suite Variable    ${s_id1}  ${resp.json()}

#     # ${s_id}=  Create Sample Service  ${SERVICE1}
#     # Set Suite Variable   ${s_id}
#     # ${SERVICE2}=   FakerLibrary.name
#     # ${s_id2}=  Create Sample Service  ${SERVICE2}
#     # Set Suite Variable   ${s_id2}
#     ${schedule_name}=  FakerLibrary.bs
#     ${parallel}=  FakerLibrary.Random Int  min=1  max=10
#     ${maxval}=  Convert To Integer   ${delta/2}
#     ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
#     ${bool1}=  Random Element  ${bool}
#     ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}  ${s_id2}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Suite Variable  ${sch_id}  ${resp.json()}

#     ${resp}=  Get Appointment Schedule ById  ${sch_id}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

#     ${sTime2}=  add_timezone_time  ${tz}  1  15  
#     ${delta}=  FakerLibrary.Random Int  min=10  max=60
#     ${eTime2}=  add_two   ${sTime2}  ${delta}   

#     ${schedule_name}=  FakerLibrary.bs
#     ${parallel}=  FakerLibrary.Random Int  min=1  max=10
#     ${maxval}=  Convert To Integer   ${delta/2}
#     ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
#     ${bool1}=  Random Element  ${bool}
#     ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime2}  ${eTime2}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id2}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Suite Variable  ${sch_id2}  ${resp.json()} 

#     ${resp}=  Get Appointment Schedule ById  ${sch_id2}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Verify Response  ${resp}  id=${sch_id2}   name=${schedule_name}  apptState=${Qstate[0]}

#     ${resp}=  ProviderLogout
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=  Consumer SignUp Notification    Hisham   Muhammed   ${MobilenumHi}     ${countryCode}   email=${Emailhisham}
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${resp}=  Consumer Activation  ${Emailhisham}  1
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${resp}=  Consumer Set Credential Notification    ${Emailhisham}   ${PASSWORD1}   1   ${countryCode}
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${resp}=  Consumer Login Notification   ${MobilenumHi}   ${PASSWORD1}   ${countryCode}
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200

#     Append To File  ${EXECDIR}/data/TDD_Logs/consumernumbers.txt  ${MobilenumHi}${\n}

#     ${resp}=  Consumer Login  ${MobilenumHi}  ${PASSWORD}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200  
#     Set Suite Variable  ${f_Name}  ${resp.json()['firstName']}
#     Set Suite Variable  ${l_Name}  ${resp.json()['lastName']}
#     Set Suite Variable  ${ph_no}  ${resp.json()['primaryPhoneNumber']}

#     ${resp}=  Get Appointment Schedules Consumer  ${pid}
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200

#     ${resp}=  Get Appointment Schedule ById Consumer  ${sch_id}   ${pid}
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200

#     ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id}   ${pid}
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
#     @{slots}=  Create List
#     FOR   ${i}  IN RANGE   0   ${no_of_slots}
#         IF  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   
            Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
        END
#     END
#     ${num_slots}=  Get Length  ${slots}
#     ${j}=  Random Int  max=${num_slots-1}
#     Set Suite Variable   ${slot1}   ${slots[${j}]}

#     ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
#     ${apptfor}=   Create List  ${apptfor1}

#     ${cid}=  get_id  ${MobilenumHi}   
#     Set Suite Variable   ${cid}
#     ${cnote}=   FakerLibrary.name
#     ${resp}=   Take Appointment For Provider   ${pid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
          
#     ${apptid}=  Get Dictionary Values  ${resp.json()}
#     Set Suite Variable  ${apptid1}  ${apptid[0]}

#     ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid1}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200 
#     Should Be Equal As Strings  ${resp.json()['uid']}                                           ${apptid1}
#     Should Be Equal As Strings  ${resp.json()['consumer']['id']}                                ${cid}
#     Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}          ${fname}
#     Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}           ${lname}
#     Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['primaryMobileNo']}    ${ph_no}
#     Should Be Equal As Strings  ${resp.json()['service']['id']}                                 ${s_id}
#     Should Be Equal As Strings  ${resp.json()['schedule']['id']}                                ${sch_id}
#     Should Be Equal As Strings  ${resp.json()['apptStatus']}                                    ${appt_status[1]}
#     Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}                      ${fname}
#     Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}                       ${lname}
#     Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}                       ${slot1}
#     Should Be Equal As Strings  ${resp.json()['appmtDate']}                                     ${DAY1}
#     Should Be Equal As Strings  ${resp.json()['appmtTime']}                                     ${slot1}
#     Should Be Equal As Strings  ${resp.json()['location']['id']}                                ${lid}


# JD-TC-Take Appointment By Provider , Reschedule Appmt add appmt attachment-1
# #  its okey
#     [Documentation]  Provider takes appointment for a valid consumer when appointment and today appointment is enabled - ok
    
#     # sms okey
#     ${resp}=  Consumer SignUp Notification    Hisham   Muhammed   ${MobilenumHi}     ${countryCode}   email=${Emailhisham}
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${resp}=  Consumer Activation  ${Emailhisham}  1
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${resp}=  Consumer Set Credential Notification    ${Emailhisham}   ${PASSWORD1}   1   ${countryCode}
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${resp}=  Consumer Login Notification   ${MobilenumHi}   ${PASSWORD1}   ${countryCode}
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200

#     Append To File  ${EXECDIR}/data/TDD_Logs/consumernumbers.txt  ${MobilenumHi}${\n}

#     ${resp}=  Consumer Login  ${MobilenumHi}  ${PASSWORD1}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200  
#     Set Suite Variable  ${f_Name}  ${resp.json()['firstName']}
#     Set Suite Variable  ${l_Name}  ${resp.json()['lastName']}
#     Set Suite Variable  ${ph_no}  ${resp.json()['primaryPhoneNumber']}

    
#     ${resp}=  Consumer Logout
#     Log   ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200

#     ${domresp}=  Get BusinessDomainsConf
#     Log  ${domresp.json()}
#     Should Be Equal As Strings  ${domresp.status_code}  200
#     ${len}=  Get Length  ${domresp.json()}
#     ${domain_list}=  Create List
#     ${subdomain_list}=  Create List
#     FOR  ${domindex}  IN RANGE  ${len}
#         Set Test Variable  ${d}  ${domresp.json()[${domindex}]['domain']}    
#         Append To List  ${domain_list}    ${d} 
#         Set Test Variable  ${sd}  ${domresp.json()[${domindex}]['subDomains'][0]['subDomain']}
#         Append To List  ${subdomain_list}    ${sd} 
#     END
#     Log  ${domain_list}
#     Log  ${subdomain_list}
#     Set Suite Variable  ${domain_list}
#     Set Suite Variable  ${subdomain_list}
#     Set Test Variable  ${d1}  ${domain_list[0]}
#     Set Test Variable  ${sd1}  ${subdomain_list[0]}

#     ${highest_package}=  get_highest_license_pkg
    
#     ${resp}=  Account SignUp   simi  Dany  ${None}  ${d1}  ${sd1}  ${ConsMobilenum}    ${highest_package[0]}
#     Log  ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${resp}=  Account Activation  ${ConsMobilenum}  0
#     Log   ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${resp}=  Account Set Credential  ${ConsMobilenum}  ${NEW_PASSWORD12}  0
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${resp}=  Encrypted Provider Login  ${ConsMobilenum}  ${NEW_PASSWORD12}
#     Log  ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${ConsMobilenum}${\n}
#     Set Suite Variable  ${ConsMobilenum}
#     ${pid}=  get_acc_id  ${ConsMobilenum}
#     ${id}=  get_id  ${ConsMobilenum}
#     Set Suite Variable  ${id}
#     ${resp}=  Encrypted Provider Login  ${ConsMobilenum}  ${NEW_PASSWORD12}
#     Log   ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200
    
#     ${resp}=   Get Service
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=    Get Locations
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=   Get Appointment Settings
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Run Keyword If  ${resp.json()['enableAppt']}==${bool[0]}   Enable Appointment

#     clear_service   ${ConsMobilenum}
#     clear_location  ${ConsMobilenum}
#     clear_customer   ${ConsMobilenum}

#     ${resp}=   Get Service
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=    Get Locations
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200

   
#     ${resp}=   Get jaldeeIntegration Settings
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${resp1}=   Run Keyword If  ${resp.json()['walkinConsumerBecomesJdCons']}==${bool[0]}   Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${EMPTY}
#     Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.json()}
#     Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200
   
#     ${resp}=   Get jaldeeIntegration Settings
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     # Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[0]}
#     Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]} 

#     ${resp}=  Get Business Profile
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable  ${pid}  ${resp.json()['id']} 


    
#     ${DAY1}=  db.get_date_by_timezone  ${tz}
#     ${list}=  Create List  1  2  3  4  5  6  7
#     ${ph1}=  Evaluate  ${ConsMobilenum}+15566122
#     ${ph2}=  Evaluate  ${ConsMobilenum}+25566122
#     ${views}=  Random Element    ${Views}
#     ${name1}=  FakerLibrary.name
#     ${name2}=  FakerLibrary.name
#     ${name3}=  FakerLibrary.name
#     ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
#     ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
#     ${emails1}=  Emails  ${name3}  Email  ${EmailProConsreshma}  ${views}
#     ${bs}=  FakerLibrary.bs
#     ${city}=   get_place
#     ${latti}=  get_latitude
#     ${longi}=  get_longitude
#     ${companySuffix}=  FakerLibrary.companySuffix
#     ${postcode}=  FakerLibrary.postcode
#     ${address}=  get_address
#     ${parking}   Random Element   ${parkingType}
#     ${24hours}    Random Element    ${bool}
#     ${desc}=   FakerLibrary.sentence
#     ${url}=   FakerLibrary.url
#     ${sTime}=  add_timezone_time  ${tz}  0  15  
#     ${eTime}=  add_timezone_time  ${tz}  0  45  
#     ${resp}=  Update Business Profile with Schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}   ${address}   ${ph_nos1}   ${ph_nos2}   ${emails1}   ${EMPTY}
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200

#     ${resp}=  Get Business Profile
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=   Get Appointment Settings
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
#     Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}  

#     ${lid}=  Create Sample Location  
#     clear_appt_schedule   ${ConsMobilenum}
    
#     ${DAY1}=  db.get_date_by_timezone  ${tz}
#     ${DAY2}=  db.add_timezone_date  ${tz}  10        
#     ${list}=  Create List  1  2  3  4  5  6  7
#   # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
#     ${delta}=  FakerLibrary.Random Int  min=10  max=60
#     ${eTime1}=  add_two   ${sTime1}  ${delta}
#     ${SERVICE1}=   FakerLibrary.name
#     ${s_id}=  Create Sample Service  ${SERVICE1}
#     ${schedule_name}=  FakerLibrary.bs
#     ${parallel}=  FakerLibrary.Random Int  min=1  max=10
#     ${maxval}=  Convert To Integer   ${delta/2}
#     ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
#     ${bool1}=  Random Element  ${bool}
#     ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable  ${sch_id}  ${resp.json()}

#     ${resp}=  Get Appointment Schedule ById  ${sch_id}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

#     ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
#     Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
#     Set Test Variable   ${slot2}   ${resp.json()['availableSlots'][1]['time']}


#     ${resp}=  AddCustomer  ${MobilenumHi}  firstName=${f_Name}   lastName=${l_Name}
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable  ${cid}   ${resp.json()}
    
#     ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
#     ${apptfor}=   Create List  ${apptfor1}

#     ${apptTime}=  db.get_tz_time_secs  ${tz} 
#     ${apptTakenTime}=  db.remove_secs   ${apptTime}
#     ${UpdatedTime}=  db.get_date_time_by_timezone  ${tz}
#     ${statusUpdatedTime}=   db.remove_date_time_secs   ${UpdatedTime}

#     ${cnote}=   FakerLibrary.word
#     ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
          
#     ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
#     Set Test Variable  ${apptid1}  ${apptid[0]}

#     ${resp}=  Get Appointment EncodedID   ${apptid1}
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${encId}=  Set Variable   ${resp.json()}

    
   
#     ${resp}=  Get Appointment By Id   ${apptid1}
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Should Be Equal As Strings  ${resp.json()['uid']}   ${apptid1}
#     Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id}
#     Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
#     Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[2]}
#     Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}   ${fname}
#     Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname}
#     Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot1}
#     Should Be Equal As Strings  ${resp.json()['appmtDate']}   ${DAY1}
#     Should Be Equal As Strings  ${resp.json()['appmtTime']}   ${slot1}
#     Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}


#     ${resp}=  Get Appointment By Id   ${apptid1}
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Should Be Equal As Strings  ${resp.json()['hasAttachment']}    ${bool[0]}

#     ${cookie}  ${resp}=  Imageupload.spLogin  ${ConsMobilenum}   ${NEW_PASSWORD12}
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${caption}=  Fakerlibrary.sentence
    
#     ${resp}=  Imageupload.PApptAttachment   ${cookie}   ${apptid1}   ${caption}   ${pngfile}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=  Get Provider Appointment Attachment   ${apptid1}
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}            200
#     Dictionary Should Contain Key  ${resp.json()[0]}   s3path
#     Should Contain  ${resp.json()[0]['s3path']}   .png
#     Dictionary Should Contain Key  ${resp.json()[0]}   thumbPath
#     Should Contain  ${resp.json()[0]['s3path']}   .png
#     Should Be Equal As Strings  ${resp.json()[0]['caption']}     ${caption} 

#     ${resp}=  Get Appointment By Id   ${apptid1}
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Should Be Equal As Strings  ${resp.json()['hasAttachment']}    ${bool[1]}

   
#     ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}

#     ${resp}=  Reschedule Consumer Appointment   ${apptid1}  ${slot2}  ${DAY1}  ${sch_id}
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=  Get Appointment By Id   ${apptid1}
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Verify Response   ${resp}  uid=${apptid1}  appmtDate=${DAY1}   appmtTime=${slot2}  
#     ...   appointmentEncId=${encId}  apptStatus=${apptStatus[2]}  

  
#     ${resp}=  Provider Logout
#     Log   ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200

#     ${resp}=  Consumer Login  ${MobilenumHi}  ${PASSWORD1}
#     Log   ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200

#     ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid1}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Verify Response   ${resp}    appmtTime=${slot2}  apptStatus=${apptStatus[2]}
#     Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}  ${fname}
#     Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname}

# JD-TC-Take Appointment By consumer And Reschedule-1

#     [Documentation]  Consumer takes appointment for a valid Provider - its ok

#     ${multilocdoms}=  get_mutilocation_domains
#     Log  ${multilocdoms}
#     Set Suite Variable  ${dom}  ${multilocdoms[0]['domain']}
#     Set Suite Variable  ${sub_dom}  ${multilocdoms[0]['subdomains'][0]}

#     ${highest_package}=  get_highest_license_pkg
#     ${resp}=  Account SignUp   Simi   Dany  ${None}  ${dom}  ${sub_dom}  ${ConsMobilenum}    ${highest_package[0]}
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${resp}=  Account Activation  ${ConsMobilenum}  0
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${resp}=  Account Set Credential  ${ConsMobilenum}  ${PASSWORD}  0
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${resp}=  Encrypted Provider Login  ${ConsMobilenum}  ${PASSWORD}
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${ConsMobilenum}${\n}
#     Set Suite Variable  ${ConsMobilenum}

#     ${resp}=  Encrypted Provider Login  ${ConsMobilenum}  ${PASSWORD}
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200

#     ${DAY1}=  db.get_date_by_timezone  ${tz}
#     ${list}=  Create List  1  2  3  4  5  6  7
#     ${ph1}=  Evaluate  ${ConsMobilenum}+15566122
#     ${ph2}=  Evaluate  ${ConsMobilenum}+25566122
#     ${views}=  Random Element    ${Views}
#     ${name1}=  FakerLibrary.name
#     ${name2}=  FakerLibrary.name
#     ${name3}=  FakerLibrary.name
#     ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
#     ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
#     ${emails1}=  Emails  ${name3}  Email  ${EmailProConsreshma}   ${views}
#     ${bs}=  FakerLibrary.bs
#     ${city}=   get_place
#     ${latti}=  get_latitude
#     ${longi}=  get_longitude
#     ${companySuffix}=  FakerLibrary.companySuffix
#     ${postcode}=  FakerLibrary.postcode
#     ${address}=  get_address
#     ${parking}   Random Element   ${parkingType}
#     ${24hours}    Random Element    ${bool}
#     ${desc}=   FakerLibrary.sentence
#     ${url}=   FakerLibrary.url
#     ${sTime}=  add_timezone_time  ${tz}  0  15  
#     ${eTime}=  add_timezone_time  ${tz}  0  45  
#     ${resp}=  Update Business Profile with Schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}   ${EMPTY}
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200

#     ${resp}=  Get Business Profile
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${fields}=   Get subDomain level Fields  ${dom}  ${sub_dom}
#     Log  ${fields.json()}
#     Should Be Equal As Strings    ${fields.status_code}   200

#     ${virtual_fields}=  get_Subdomainfields  ${fields.json()}

#     ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${sub_dom}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=  Get specializations Sub Domain  ${dom}  ${sub_dom}
#     Should Be Equal As Strings    ${resp.status_code}   200

#     ${spec}=  get_Specializations  ${resp.json()}
#     ${resp}=  Update Specialization  ${spec}
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}   200

#     ${resp}=  Enable Appointment
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     sleep   01s
    
#     ${resp}=  Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[0]}  ${boolean[0]}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${resp}=  Get jaldeeIntegration Settings
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}

#     ${resp}=   Get Appointment Settings
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
#     Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}

#     clear_service   ${ConsMobilenum}
#     clear_location  ${ConsMobilenum}    
#     ${resp}=   Get Service
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=    Get Locations
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${pid}=  get_acc_id  ${ConsMobilenum}
#     Set Suite Variable   ${pid}
#     ${DAY1}=  db.get_date_by_timezone  ${tz}
#     Set Suite Variable   ${DAY1}
#     ${DAY2}=  db.add_timezone_date  ${tz}  10        
#     ${list}=  Create List  1  2  3  4  5  6  7
#     ${sTime1}=  add_timezone_time  ${tz}  0  15  
#     ${delta}=  FakerLibrary.Random Int  min=10  max=60
#     ${eTime1}=  add_two   ${sTime1}  ${delta}
#     ${lid}=  Create Sample Location
#     Set Suite Variable   ${lid}
#     clear_appt_schedule   ${ConsMobilenum}
#     ${SERVICE1}=   FakerLibrary.name
#     ${s_id}=  Create Sample Service  ${SERVICE1}
#     Set Suite Variable   ${s_id}
#     ${SERVICE2}=   FakerLibrary.name
#     ${s_id2}=  Create Sample Service  ${SERVICE2}
#     Set Suite Variable   ${s_id2}
#     ${schedule_name}=  FakerLibrary.bs
#     ${parallel}=  FakerLibrary.Random Int  min=1  max=10
#     ${maxval}=  Convert To Integer   ${delta/2}
#     ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
#     ${bool1}=  Random Element  ${bool}
#     ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}  ${s_id2}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Suite Variable  ${sch_id}  ${resp.json()}

#     ${resp}=  Get Appointment Schedule ById  ${sch_id}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

#     ${sTime2}=  add_timezone_time  ${tz}  1  15  
#     ${delta}=  FakerLibrary.Random Int  min=10  max=60
#     ${eTime2}=  add_two   ${sTime2}  ${delta}   

#     ${schedule_name}=  FakerLibrary.bs
#     ${parallel}=  FakerLibrary.Random Int  min=1  max=10
#     ${maxval}=  Convert To Integer   ${delta/2}
#     ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
#     ${bool1}=  Random Element  ${bool}
#     ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime2}  ${eTime2}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id2}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Suite Variable  ${sch_id2}  ${resp.json()} 

#     ${resp}=  Get Appointment Schedule ById  ${sch_id2}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Verify Response  ${resp}  id=${sch_id2}   name=${schedule_name}  apptState=${Qstate[0]}


#     ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
   
  
#     ${resp}=  Get Appointment Messages
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}   200
#     ${confirmAppt_push}=  Set Variable   ${resp.json()['confirmationMessages']['Consumer_APP']} 
#     ${defreschedule_msg}=  Set Variable   ${resp.json()['rescheduleMessages']['Consumer_APP']}


#     ${resp}=  ProviderLogout
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=  Consumer SignUp Notification    Hisham   Muhammed   ${MobilenumHi}     ${countryCode}   email=${Emailhisham}
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${resp}=  Consumer Activation  ${Emailhisham}  1
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${resp}=  Consumer Set Credential Notification    ${Emailhisham}   ${PASSWORD1}   1   ${countryCode}
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${resp}=  Consumer Login Notification   ${MobilenumHi}   ${PASSWORD1}   ${countryCode}
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200

#     Append To File  ${EXECDIR}/data/TDD_Logs/consumernumbers.txt  ${MobilenumHi}${\n}

#     ${resp}=  Consumer Login  ${MobilenumHi}  ${PASSWORD1}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200  
#     Set Suite Variable  ${f_Name}  ${resp.json()['firstName']}
#     Set Suite Variable  ${l_Name}  ${resp.json()['lastName']}
#     Set Suite Variable  ${ph_no}  ${resp.json()['primaryPhoneNumber']}
#     Set Test Variable  ${uname}   ${resp.json()['userName']}

#     ${resp}=  Get Appointment Schedules Consumer  ${pid}
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200

#     ${resp}=  Get Appointment Schedule ById Consumer  ${sch_id}   ${pid}
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200


#     ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id}   ${pid}
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
#     @{slots}=  Create List
#     FOR   ${i}  IN RANGE   0   ${no_of_slots}
#         IF  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   
            Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
        END
#     END
#     ${num_slots}=  Get Length  ${slots}
#     ${j}=  Random Int  max=${num_slots-1}
#     Set Suite Variable   ${slot1}   ${slots[${j}]}

#     ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
#     ${apptfor}=   Create List  ${apptfor1}

#     ${cid}=  get_id  ${MobilenumHi}   
#     Set Suite Variable   ${cid}
#     ${cnote}=   FakerLibrary.name
#     ${resp}=   Take Appointment For Provider   ${pid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
          
#     ${apptid}=  Get Dictionary Values  ${resp.json()}
#     Set Suite Variable  ${apptid1}  ${apptid[0]}

#     ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid1}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200 
#     Should Be Equal As Strings  ${resp.json()['uid']}                                           ${apptid1}
#     Should Be Equal As Strings  ${resp.json()['consumer']['id']}                                ${cid}
#     Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}          ${f_Name} 
#     Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}           ${l_Name}
#     Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['primaryMobileNo']}    ${ph_no}
#     Should Be Equal As Strings  ${resp.json()['service']['id']}                                 ${s_id}
#     Should Be Equal As Strings  ${resp.json()['schedule']['id']}                                ${sch_id}
#     Should Be Equal As Strings  ${resp.json()['apptStatus']}                                    ${appt_status[1]}
#     Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}                      ${fname}
#     Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}                       ${lname}
#     Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}                       ${slot1}
#     Should Be Equal As Strings  ${resp.json()['appmtDate']}                                     ${DAY1}
#     Should Be Equal As Strings  ${resp.json()['appmtTime']}                                     ${slot1}
#     Should Be Equal As Strings  ${resp.json()['location']['id']}                                ${lid}

   
#    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id}   ${pid}
#     Log   ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
#     @{slots}=  Create List
#     FOR   ${i}  IN RANGE   0   ${no_of_slots}
#         IF  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   
            Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
        END
#     END
#     ${num_slots}=  Get Length  ${slots}
#     FOR   ${i}  IN RANGE   0   ${num_slots}
#         ${j2}=  Random Int  max=${num_slots-1}
#         Exit For Loop If  "${resp.json()['availableSlots'][${j2}]['time']}" != "${slot1}"
#     END
#     Set Test Variable   ${slot2}   ${resp.json()['availableSlots'][${j2}]['time']}

#     ${resp}=  Reschedule Appointment   ${pid}   ${apptid1}  ${slot2}  ${DAY1}  ${sch_id}
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid1}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200 
#     Verify Response   ${resp}     uid=${apptid1}   appmtDate=${DAY1}   appmtTime=${slot2}
#     ...  apptStatus=${apptStatus[1]} 
#     Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${cid}
#     Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${fname}
#     Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${lname}
#     Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id}
#     Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
#     Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}  ${fname}
#     Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname}
#     Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot2}
#     Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}
    
#     ${resp}=    Get Appmt Service By LocationId   ${lid}
#     Log   ${resp.json()}
#     Should Be Equal As Strings   ${resp.status_code}   200

#     ${resp}=  Encrypted Provider Login  ${ConsMobilenum}  ${PASSWORD}
#     Log   ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200

#     ${resp}=   Get Appointment EncodedID    ${apptid1}
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${encId}=  Set Variable   ${resp.json()}
#     Set Test Variable   ${encId}   

#     ${resp}=  Provider Logout
#     Log   ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200

#     ${resp}=  Consumer Login  ${MobilenumHi}  ${PASSWORD1}
#     Log   ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200

#     sleep   03s

#     ${bookingid}=  Format String  ${bookinglink}  ${encId}  ${encId}
#     ${defconfirm_msg}=  Replace String  ${confirmAppt_push}  [consumer]   ${uname}
#     ${defconfirm_msg}=  Replace String  ${defconfirm_msg}  [bookingId]   ${encId}

#     ${defreschedule_msg}=  Replace String  ${defreschedule_msg}  [consumer]   ${uname}
#     ${defreschedule_msg}=  Replace String  ${defreschedule_msg}  [bookingId]   ${encId}

#     ${resp}=  Get Consumer Communications
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     # Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}        0
#     # Should Be Equal As Strings  ${resp.json()[0]['waitlistId']}         ${apptid1}
#     # Should Be Equal As Strings  ${resp.json()[0]['msg']}                ${defconfirm_msg}
#     # Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}     ${cid} 

#     # Should Be Equal As Strings  ${resp.json()[1]['owner']['id']}        0
#     # Should Be Equal As Strings  ${resp.json()[1]['waitlistId']}         ${apptid1}
#     # Should Be Equal As Strings  ${resp.json()[1]['msg']}                ${defreschedule_msg}
#     # Should Be Equal As Strings  ${resp.json()[1]['receiver']['id']}     ${cid}

#     ${resp}=  Consumer Logout
#     Log   ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200

#     ${resp}=  Encrypted Provider Login  ${ConsMobilenum}  ${PASSWORD}
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=  Get provider communications
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     # Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}        0
#     # Should Be Equal As Strings  ${resp.json()[0]['waitlistId']}         ${apptid1}
#     # Should Be Equal As Strings  ${resp.json()[0]['msg']}                ${defconfirm_msg}
#     # Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}     ${cid} 

#     # Should Be Equal As Strings  ${resp.json()[1]['owner']['id']}        0
#     # Should Be Equal As Strings  ${resp.json()[1]['waitlistId']}         ${apptid1}
#     # Should Be Equal As Strings  ${resp.json()[1]['msg']}                ${defreschedule_msg}
#     # Should Be Equal As Strings  ${resp.json()[1]['receiver']['id']}     ${cid}

#     ${resp}=  Provider Logout
#     Log   ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200

#  *** Comments ***
# JD-TC-Update License -1
#     [Documentation]  Update License Package with valid data - its ok

#     ${multilocdoms}=  get_mutilocation_domains
#     Log  ${multilocdoms}
#     Set Suite Variable  ${dom}  ${multilocdoms[0]['domain']}
#     Set Suite Variable  ${sub_dom}  ${multilocdoms[0]['subdomains'][0]}

#     # ${highest_package}=  get_highest_license_pkg
#     ${resp}=  Account SignUp   Simi   Dany  ${None}  ${dom}  ${sub_dom}  ${ConsMobilenum}    1
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${resp}=  Account Activation  ${ConsMobilenum}  0
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${resp}=  Account Set Credential  ${ConsMobilenum}  ${PASSWORD}  0
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${resp}=  Encrypted Provider Login  ${ConsMobilenum}  ${PASSWORD}
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${ConsMobilenum}${\n}
#     Set Suite Variable  ${ConsMobilenum}
#     Set Suite Variable  ${old_pkgid}  ${resp.json()['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']} 

#     ${DAY1}=  db.get_date_by_timezone  ${tz}
#     ${list}=  Create List  1  2  3  4  5  6  7
#     ${ph1}=  Evaluate  ${ConsMobilenum}+15566122
#     ${ph2}=  Evaluate  ${ConsMobilenum}+25566122
#     ${views}=  Random Element    ${Views}
#     ${name1}=  FakerLibrary.name
#     ${name2}=  FakerLibrary.name
#     ${name3}=  FakerLibrary.name
#     ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
#     ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
#     ${emails1}=  Emails  ${name3}  Email  ${EmailProConsreshma}   ${views}
#     ${bs}=  FakerLibrary.bs
#     ${city}=   get_place
#     ${latti}=  get_latitude
#     ${longi}=  get_longitude
#     ${companySuffix}=  FakerLibrary.companySuffix
#     ${postcode}=  FakerLibrary.postcode
#     ${address}=  get_address
#     ${parking}   Random Element   ${parkingType}
#     ${24hours}    Random Element    ${bool}
#     ${desc}=   FakerLibrary.sentence
#     ${url}=   FakerLibrary.url
#     ${sTime}=  add_timezone_time  ${tz}  0  15  
#     ${eTime}=  add_timezone_time  ${tz}  0  45  
#     ${resp}=  Update Business Profile with Schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}   ${EMPTY}
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200

#     ${resp}=  Get Business Profile
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
     
#      ${fields}=   Get subDomain level Fields  ${dom}  ${sub_dom}
#     Log  ${fields.json()}
#     Should Be Equal As Strings    ${fields.status_code}   200

#     ${virtual_fields}=  get_Subdomainfields  ${fields.json()}

#     ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${sub_dom}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=  Get specializations Sub Domain  ${dom}  ${sub_dom}
#     Should Be Equal As Strings    ${resp.status_code}   200

#     ${spec}=  get_Specializations  ${resp.json()}
#     ${resp}=  Update Specialization  ${spec}
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}   200

#     ${resp}=  Enable Appointment
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     sleep   01s
    
#     ${resp}=  Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[0]}  ${boolean[0]}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${resp}=  Get jaldeeIntegration Settings
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}

#     ${resp}=   Get Appointment Settings
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
#     Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}

#       ${resp}=   Get upgradable license
#       Should Be Equal As Strings    ${resp.status_code}   200
#       Set Test Variable  ${pkgid}  ${resp.json()[0]['pkgId']} 
#       Set Test Variable  ${pkgname}  ${resp.json()[0]['pkgName']}
#       ${resp}=  Change License Package  ${pkgid}
#       Should Be Equal As Strings    ${resp.status_code}   200
#       ${resp}=  Get Active License
#       Should Be Equal As Strings    ${resp.status_code}    200
#       Should Be Equal As Strings  ${resp.json()['accountLicense']['licPkgOrAddonId']}   ${pkgid}
#       Should Be Equal As Strings  ${resp.json()['accountLicense']['name']}   ${pkgname}

#       ${resp}=   Get upgradable license
#       Should Be Equal As Strings    ${resp.status_code}   200
#       Set Suite Variable  ${pkgid}  ${resp.json()[0]['pkgId']} 
#       Set Suite Variable  ${pkgname}  ${resp.json()[0]['pkgName']}
#       ${resp}=  Change License Package  ${pkgid}
#       Should Be Equal As Strings    ${resp.status_code}   200
#       ${resp}=  Get Active License
#       Should Be Equal As Strings    ${resp.status_code}    200
#       Should Be Equal As Strings  ${resp.json()['accountLicense']['licPkgOrAddonId']}   ${pkgid}
#       Should Be Equal As Strings  ${resp.json()['accountLicense']['name']}   ${pkgname}

# JD-TC-GetWaitlistById , Reschedule ,waitlist attachment-1

#     [Documentation]  Get Waitlist details for the current day - okey booking and reschedule

#     ${resp}=  Consumer SignUp Notification    Hisham   Muhammed   ${MobilenumHi}     ${countryCode}   email=${Emailhisham}
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${resp}=  Consumer Activation  ${Emailhisham}  1
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${resp}=  Consumer Set Credential Notification    ${Emailhisham}   ${PASSWORD1}   1   ${countryCode}
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${resp}=  Consumer Login Notification   ${MobilenumHi}   ${PASSWORD1}   ${countryCode}
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200

#     Append To File  ${EXECDIR}/data/TDD_Logs/consumernumbers.txt  ${MobilenumHi}${\n}

#     ${resp}=  Consumer Login  ${MobilenumHi}  ${PASSWORD1}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200  
#     Set Suite Variable  ${f_Name}  ${resp.json()['firstName']}
#     Set Suite Variable  ${l_Name}  ${resp.json()['lastName']}
#     Set Suite Variable  ${ph_no}  ${resp.json()['primaryPhoneNumber']}

    
#     ${resp}=  Consumer Logout
#     Log   ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200


#     ${domresp}=  Get BusinessDomainsConf

#     Log  ${domresp.json()}
#     Should Be Equal As Strings  ${domresp.status_code}  200
#     ${len}=  Get Length  ${domresp.json()}
#     ${domain_list}=  Create List
#     ${subdomain_list}=  Create List
#     FOR  ${domindex}  IN RANGE  ${len}
#         Set Test Variable  ${d}  ${domresp.json()[${domindex}]['domain']}    
#         Append To List  ${domain_list}    ${d} 
#         Set Test Variable  ${sd}  ${domresp.json()[${domindex}]['subDomains'][0]['subDomain']}
#         Append To List  ${subdomain_list}    ${sd} 
#     END
#     Log  ${domain_list}
#     Log  ${subdomain_list}
#     Set Suite Variable  ${domain_list}
#     Set Suite Variable  ${subdomain_list}
#     Set Test Variable  ${d1}  ${domain_list[0]}
#     Set Test Variable  ${sd1}  ${subdomain_list[0]}

#     ${highest_package}=  get_highest_license_pkg
    
#     ${resp}=  Account SignUp   simi  Dany  ${None}  ${d1}  ${sd1}  ${ConsMobilenum}    ${highest_package[0]}
#     Log  ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${resp}=  Account Activation  ${ConsMobilenum}  0
#     Log   ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${resp}=  Account Set Credential  ${ConsMobilenum}  ${NEW_PASSWORD12}  0
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${resp}=  Encrypted Provider Login  ${ConsMobilenum}  ${NEW_PASSWORD12}
#     Log  ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${ConsMobilenum}${\n}
#     Set Suite Variable  ${ConsMobilenum}
#     ${pid}=  get_acc_id  ${ConsMobilenum}
#     ${id}=  get_id  ${ConsMobilenum}
#     Set Suite Variable  ${id}
#     ${resp}=  Encrypted Provider Login  ${ConsMobilenum}  ${NEW_PASSWORD12}
#     Log   ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200
    
#     ${resp}=   Get Service
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=    Get Locations
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=   Get Appointment Settings
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Run Keyword If  ${resp.json()['enableAppt']}==${bool[0]}   Enable Appointment

#     clear_service   ${ConsMobilenum}
#     clear_location  ${ConsMobilenum}
#     clear_customer   ${ConsMobilenum}

#     ${resp}=   Get Service
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=    Get Locations
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200

    
#     # ${resp}=   Get jaldeeIntegration Settings
#     # Log   ${resp.json()}
#     # Should Be Equal As Strings  ${resp.status_code}  200
#     # ${resp1}=   Run Keyword If  ${resp.json()['walkinConsumerBecomesJdCons']}==${bool[0]}   Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${EMPTY}
#     # Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.json()}
#     # Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200
   
#     # ${resp}=   Get jaldeeIntegration Settings
#     # Log   ${resp.json()}
#     # Should Be Equal As Strings  ${resp.status_code}  200
#     # # Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[0]}
#     # Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]} 

#     ${resp}=  Get Business Profile
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable  ${pid}  ${resp.json()['id']} 


    
#     ${DAY1}=  db.get_date_by_timezone  ${tz}
#     ${list}=  Create List  1  2  3  4  5  6  7
#     ${ph1}=  Evaluate  ${ConsMobilenum}+15566122
#     ${ph2}=  Evaluate  ${ConsMobilenum}+25566122
#     ${views}=  Random Element    ${Views}
#     ${name1}=  FakerLibrary.name
#     ${name2}=  FakerLibrary.name
#     ${name3}=  FakerLibrary.name
#     ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
#     ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
#     ${emails1}=  Emails  ${name3}  Email  ${EmailProConsreshma}  ${views}
#     ${bs}=  FakerLibrary.bs
#     ${city}=   get_place
#     ${latti}=  get_latitude
#     ${longi}=  get_longitude
#     ${companySuffix}=  FakerLibrary.companySuffix
#     ${postcode}=  FakerLibrary.postcode
#     ${address}=  get_address
#     ${parking}   Random Element   ${parkingType}
#     ${24hours}    Random Element    ${bool}
#     ${desc}=   FakerLibrary.sentence
#     ${url}=   FakerLibrary.url
#     ${sTime}=  add_timezone_time  ${tz}  0  15  
#     ${eTime}=  add_timezone_time  ${tz}  0  45  
#     ${resp}=  Update Business Profile with Schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}   ${address}   ${ph_nos1}   ${ph_nos2}   ${emails1}   ${EMPTY}
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200

#     ${resp}=  Get Business Profile
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=  Enable Waitlist
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     sleep   01s

#     ${resp}=   Get jaldeeIntegration Settings
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${resp1}=   Run Keyword If  ${resp.json()['walkinConsumerBecomesJdCons']}==${bool[0]}   Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${EMPTY}
#     Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.json()}
#     Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200
   
#     ${resp}=   Get jaldeeIntegration Settings
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     # Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[0]}
#     Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]} 


#     ${resp}=  Update Waitlist Settings  ${calc_mode[0]}  ${EMPTY}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${EMPTY} 
#     Should Be Equal As Strings  ${resp.status_code}  200



#     ${resp}=  AddCustomer  ${MobilenumHi}  firstName=${f_Name}   lastName=${l_Name}
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable  ${cid}   ${resp.json()}

#     ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
#     Set Suite Variable  ${CUR_DAY}
#     ${DAY3}=  db.add_timezone_date  ${tz}  4  
#     ${resp}=   Create Sample Location
#     Set Suite Variable    ${loc_id1}    ${resp}  
#     ${resp}=   Create Sample Location
#     Set Suite Variable    ${loc_id2}    ${resp}  
#     ${ser_name1}=   FakerLibrary.word
#     Set Suite Variable    ${ser_name1} 
#     ${resp}=   Create Sample Service  ${ser_name1}
#     Set Suite Variable    ${ser_id1}    ${resp}  
#     ${q_name}=    FakerLibrary.name
#     Set Suite Variable    ${q_name}
#     ${list}=  Create List   1  2  3  4  5  6  7
#     Set Suite Variable    ${list}
#     ${strt_time}=   add_timezone_time  ${tz}  1  00  
#     Set Suite Variable    ${strt_time}
#     ${end_time}=    add_timezone_time  ${tz}  3  00   
#     Set Suite Variable    ${end_time}  
#     ${parallel}=   Random Int  min=1   max=2
#     Set Suite Variable   ${parallel}
#     ${capacity}=  Random Int   min=10   max=20
#     Set Suite Variable   ${capacity} 
#     ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${loc_id2}  ${ser_id1} 
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Suite Variable  ${que_id1}   ${resp.json()}  
#     # sleep  2s  
#     ${desc}=   FakerLibrary.word
#     ${resp}=  Add To Waitlist  ${cid}  ${ser_id1}  ${que_id1}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid}
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${wid}=  Get Dictionary Values  ${resp.json()}
#     Set Suite Variable  ${wid}  ${wid[0]}
#     ${resp}=  Get Waitlist By Id  ${wid} 
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[1]}   partySize=1  appxWaitingTime=0        personsAhead=0
#     Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${ser_name1}
#     Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${ser_id1}
#     Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid}
#     Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid}

#     ${resp}=  Get Waitlist By Id  ${wid} 
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Should Be Equal As Strings  ${resp.json()['hasAttachment']}    ${bool[0]}

#     ${cookie}  ${resp}=  Imageupload.spLogin  ${ConsMobilenum}   ${NEW_PASSWORD12}
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Suite Variable  ${cookie}
#     ${caption}=  Fakerlibrary.sentence
    
#     ${resp}=  Imageupload.PWLAttachment   ${cookie}   ${wid}   ${caption}    ${pngfile}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=  Get Provider Waitlist Attachment   ${wid}
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}            200
#     Dictionary Should Contain Key  ${resp.json()[0]}   s3path
#     Should Contain  ${resp.json()[0]['s3path']}   .png
#     Dictionary Should Contain Key  ${resp.json()[0]}   thumbPath
#     Should Contain  ${resp.json()[0]['s3path']}   .png
#     Should Be Equal As Strings  ${resp.json()[0]['caption']}     ${caption} 

#     ${resp}=  Get Waitlist By Id  ${wid} 
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Should Be Equal As Strings  ${resp.json()['hasAttachment']}    ${bool[1]}

#     ${resp}=  Reschedule Consumer Checkin   ${wid}  ${DAY3}  ${que_id1}
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200


#     sleep  05s

#     ${resp}=  Get provider communications
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}   200

#     ${resp}=  Get Consumer Communications
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=  Get Appointment Messages
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}   200

# JD-TC-CreateQueue with token-1
#     [Documentation]    Create a queue with field tokenStart in a location then create a another queue with another token start then check 2nd queue token start and check third queue token start.
   
#     ${resp}=  Consumer SignUp Notification    Hisham   Muhammed   ${MobilenumHi}     ${countryCode}   email=${Emailhisham}
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${resp}=  Consumer Activation  ${Emailhisham}  1
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${resp}=  Consumer Set Credential Notification    ${Emailhisham}   ${PASSWORD1}   1   ${countryCode}
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${resp}=  Consumer Login Notification   ${MobilenumHi}   ${PASSWORD1}   ${countryCode}
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200

#     Append To File  ${EXECDIR}/data/TDD_Logs/consumernumbers.txt  ${MobilenumHi}${\n}

#     ${resp}=  Consumer Login  ${MobilenumHi}  ${PASSWORD1}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200  
#     Set Suite Variable  ${f_Name}  ${resp.json()['firstName']}
#     Set Suite Variable  ${l_Name}  ${resp.json()['lastName']}
#     Set Suite Variable  ${ph_no}  ${resp.json()['primaryPhoneNumber']}

    
#     ${resp}=  Consumer Logout
#     Log   ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200

   
#     ${domresp}=  Get BusinessDomainsConf

#     Log  ${domresp.json()}
#     Should Be Equal As Strings  ${domresp.status_code}  200
#     ${len}=  Get Length  ${domresp.json()}
#     ${domain_list}=  Create List
#     ${subdomain_list}=  Create List
#     FOR  ${domindex}  IN RANGE  ${len}
#         Set Test Variable  ${d}  ${domresp.json()[${domindex}]['domain']}    
#         Append To List  ${domain_list}    ${d} 
#         Set Test Variable  ${sd}  ${domresp.json()[${domindex}]['subDomains'][0]['subDomain']}
#         Append To List  ${subdomain_list}    ${sd} 
#     END
#     Log  ${domain_list}
#     Log  ${subdomain_list}
#     Set Suite Variable  ${domain_list}
#     Set Suite Variable  ${subdomain_list}
#     Set Test Variable  ${d1}  ${domain_list[0]}
#     Set Test Variable  ${sd1}  ${subdomain_list[0]}

#     ${highest_package}=  get_highest_license_pkg
    
#     ${resp}=  Account SignUp   simi  Dany  ${None}  ${d1}  ${sd1}  ${ConsMobilenum}    ${highest_package[0]}
#     Log  ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${resp}=  Account Activation  ${ConsMobilenum}  0
#     Log   ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${resp}=  Account Set Credential  ${ConsMobilenum}  ${NEW_PASSWORD12}  0
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${resp}=  Encrypted Provider Login  ${ConsMobilenum}  ${NEW_PASSWORD12}
#     Log  ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${ConsMobilenum}${\n}
#     Set Suite Variable  ${ConsMobilenum}
#     ${pid}=  get_acc_id  ${ConsMobilenum}
#     ${id}=  get_id  ${ConsMobilenum}
#     Set Suite Variable  ${id}
#     ${resp}=  Encrypted Provider Login  ${ConsMobilenum}  ${NEW_PASSWORD12}
#     Log   ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200
    
#     ${resp}=   Get Service
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=    Get Locations
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=   Get Appointment Settings
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Run Keyword If  ${resp.json()['enableAppt']}==${bool[0]}   Enable Appointment

#     clear_service   ${ConsMobilenum}
#     clear_location  ${ConsMobilenum}
#     clear_customer   ${ConsMobilenum}

#     ${resp}=   Get Service
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=    Get Locations
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200

    
#     ${resp}=  Get Business Profile
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable  ${pid}  ${resp.json()['id']} 
    
#     ${DAY1}=  db.get_date_by_timezone  ${tz}
#     ${list}=  Create List  1  2  3  4  5  6  7
#     ${ph1}=  Evaluate  ${ConsMobilenum}+15566122
#     ${ph2}=  Evaluate  ${ConsMobilenum}+25566122
#     ${views}=  Random Element    ${Views}
#     ${name1}=  FakerLibrary.name
#     ${name2}=  FakerLibrary.name
#     ${name3}=  FakerLibrary.name
#     ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
#     ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
#     ${emails1}=  Emails  ${name3}  Email  ${EmailProConsreshma}  ${views}
#     ${bs}=  FakerLibrary.bs
#     ${city}=   get_place
#     ${latti}=  get_latitude
#     ${longi}=  get_longitude
#     ${companySuffix}=  FakerLibrary.companySuffix
#     ${postcode}=  FakerLibrary.postcode
#     ${address}=  get_address
#     ${parking}   Random Element   ${parkingType}
#     ${24hours}    Random Element    ${bool}
#     ${desc}=   FakerLibrary.sentence
#     ${url}=   FakerLibrary.url
#     ${sTime}=  add_timezone_time  ${tz}  0  15  
#     ${eTime}=  add_timezone_time  ${tz}  0  45  
#     ${resp}=  Update Business Profile with Schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}   ${address}   ${ph_nos1}   ${ph_nos2}   ${emails1}   ${EMPTY}
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200

#     ${resp}=  Get Business Profile
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=  Enable Waitlist
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     sleep   01s

#     ${resp}=   Get jaldeeIntegration Settings
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${resp1}=   Run Keyword If  ${resp.json()['walkinConsumerBecomesJdCons']}==${bool[0]}   Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${EMPTY}
#     Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.json()}
#     Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200
   
#     ${resp}=   Get jaldeeIntegration Settings
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     # Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[0]}
#     Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]} 


#     ${resp}=  Update Waitlist Settings  ${calc_mode[0]}  ${EMPTY}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${EMPTY} 
#     Should Be Equal As Strings  ${resp.status_code}  200



#     ${resp}=  AddCustomer  ${MobilenumHi}  firstName=${f_Name}   lastName=${l_Name}
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable  ${cid}   ${resp.json()}

#     # ${resp}=  Encrypted Provider Login  ${PUSERNAME180}  ${PASSWORD}
#     # Should Be Equal As Strings    ${resp.status_code}    200
#     ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
#     Set Suite Variable  ${CUR_DAY}
#     ${DAY2}=  db.add_timezone_date  ${tz}  4  
#     # clear_service   ${PUSERNAME180}
#     # clear_location  ${PUSERNAME180}
#     # clear_queue  ${PUSERNAME180}
#     ${sTime1}=  add_timezone_time  ${tz}  0  15  
#     Set Suite Variable   ${sTime1}
#     ${eTime1}=  add_timezone_time  ${tz}  0  30  
#     Set Suite Variable   ${eTime1}
#     ${lid}=  Create Sample Location
#      ${SERVICE1}=   FakerLibrary.word
#     Set Suite Variable    ${SERVICE1} 
#     ${s_id}=  Create Sample Service  ${SERVICE1}
#      ${SERVICE2}=   FakerLibrary.word
#     Set Suite Variable    ${SERVICE2} 
#     ${s_id1}=  Create Sample Service  ${SERVICE2}
#     ${queue_name}=  FakerLibrary.bs
#     ${token_start}=   Random Int  min=5   max=40
#     ${queue_capacity}=   Random Int  min=5   max=100
#     ${resp}=  Create Queue With TokenStart  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  ${queue_capacity}  ${lid}  ${token_start}  ${s_id}  ${s_id1}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable  ${q_id}  ${resp.json()}
#     ${resp}=  Get Queue ById  ${q_id}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Should Be Equal As Strings  ${resp.json()['name']}  ${queue_name} 
#     Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
#     Should Be Equal As Strings  ${resp.json()['queueSchedule']['recurringType']}  ${recurringtype[1]}
#     Should Be Equal As Strings  ${resp.json()['queueSchedule']['repeatIntervals']}  ${list}
#     Should Be Equal As Strings  ${resp.json()['queueSchedule']['startDate']}  ${DAY1}
#     Should Be Equal As Strings  ${resp.json()['queueSchedule']['terminator']['endDate']}  ${DAY2}
#     Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['sTime']}  ${sTime1}
#     Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['eTime']}  ${eTime1}
#     Should Be Equal As Strings  ${resp.json()['parallelServing']}  1
#     Should Be Equal As Strings  ${resp.json()['capacity']}  ${queue_capacity}
#     Should Be Equal As Strings  ${resp.json()['queueState']}  ${Qstate[0]}
#     Should Be Equal As Strings  ${resp.json()['tokenStarts']}  ${token_start}
#     Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}
#     Should Be Equal As Strings  ${resp.json()['services'][1]['id']}  ${s_id1}

#     ${sTime5}=  add_timezone_time  ${tz}  1  15  
#     ${eTime5}=  add_timezone_time  ${tz}  1  30  
#     ${token_start}=   Random Int  min=45   max=60
#     ${queue_capacity}=   Random Int  min=1000   max=2000
#     ${queue_name}=  FakerLibrary.bs
#     ${resp}=  Create Queue With TokenStart  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime5}  ${eTime5}  1  ${queue_capacity}  ${lid}  ${token_start}  ${s_id1}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable  ${q_id1}  ${resp.json()}

#     ${resp}=  Get Queue ById  ${q_id1}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Should Be Equal As Strings  ${resp.json()['name']}  ${queue_name} 
#     Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
#     Should Be Equal As Strings  ${resp.json()['queueSchedule']['recurringType']}  ${recurringtype[1]}
#     Should Be Equal As Strings  ${resp.json()['queueSchedule']['repeatIntervals']}  ${list}
#     Should Be Equal As Strings  ${resp.json()['queueSchedule']['startDate']}  ${DAY1}
#     Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['sTime']}  ${sTime5}
#     Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['eTime']}  ${eTime5}
#     Should Be Equal As Strings  ${resp.json()['parallelServing']}  1
#     Should Be Equal As Strings  ${resp.json()['capacity']}  ${queue_capacity}
#     Should Be Equal As Strings  ${resp.json()['queueState']}  ${Qstate[0]}
#     Should Be Equal As Strings  ${resp.json()['tokenStarts']}  ${token_start}
#     Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id1}

#     ${queue_start}=  Evaluate  ${token_start}+${queue_capacity}
#     ${next_queue_start}=  Evaluate  (${queue_start}/100+1)*100
#     ${sTime5}=  add_timezone_time  ${tz}  2  15  
#     ${eTime5}=  add_timezone_time  ${tz}  2  30  
#     ${queue_name}=  FakerLibrary.bs
#     ${resp}=  Create Queue  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime5}  ${eTime5}  1  5  ${lid}  ${s_id1}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable  ${q_id1}  ${resp.json()}

#     ${resp}=  Get Queue ById  ${q_id1}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Should Be Equal As Strings  ${resp.json()['name']}  ${queue_name} 
#     Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
#     Should Be Equal As Strings  ${resp.json()['queueSchedule']['recurringType']}  ${recurringtype[1]}
#     Should Be Equal As Strings  ${resp.json()['queueSchedule']['repeatIntervals']}  ${list}
#     Should Be Equal As Strings  ${resp.json()['queueSchedule']['startDate']}  ${DAY1}
#     Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['sTime']}  ${sTime5}
#     Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['eTime']}  ${eTime5}
#     Should Be Equal As Strings  ${resp.json()['parallelServing']}  1
#     Should Be Equal As Strings  ${resp.json()['capacity']}  5
#     Should Be Equal As Strings  ${resp.json()['queueState']}  ${Qstate[0]}
#     Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id1}


# Appointment Cancellation-8

#    [Documentation]  Send appointment communication message to Provider after cancelling appointment.
    # Comment its okey sms varified
    
    # ${resp}=  Consumer SignUp Notification    Hisham   Muhammed   ${MobilenumHi}     ${countryCode}   email=${Emailhisham}
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # ${resp}=  Consumer Activation  ${Emailhisham}  1
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # ${resp}=  Consumer Set Credential Notification    ${Emailhisham}   ${PASSWORD1}   1   ${countryCode}
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # ${resp}=  Consumer Login Notification   ${MobilenumHi}   ${PASSWORD1}   ${countryCode}
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200

    # Append To File  ${EXECDIR}/data/TDD_Logs/consumernumbers.txt  ${MobilenumHi}${\n}

    # ${resp}=  Consumer Login  ${MobilenumHi}  ${PASSWORD1}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200  
    # Set Suite Variable  ${f_Name}  ${resp.json()['firstName']}
    # Set Suite Variable  ${l_Name}  ${resp.json()['lastName']}
    # Set Suite Variable  ${ph_no}  ${resp.json()['primaryPhoneNumber']}

    
    # ${resp}=  Consumer Logout
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200

    # ${domresp}=  Get BusinessDomainsConf
    # Log  ${domresp.json()}
    # Should Be Equal As Strings  ${domresp.status_code}  200
    # ${len}=  Get Length  ${domresp.json()}
    # ${domain_list}=  Create List
    # ${subdomain_list}=  Create List
    # FOR  ${domindex}  IN RANGE  ${len}
    #     Set Test Variable  ${d}  ${domresp.json()[${domindex}]['domain']}    
    #     Append To List  ${domain_list}    ${d} 
    #     Set Test Variable  ${sd}  ${domresp.json()[${domindex}]['subDomains'][0]['subDomain']}
    #     Append To List  ${subdomain_list}    ${sd} 
    # END
    # Log  ${domain_list}
    # Log  ${subdomain_list}
    # Set Suite Variable  ${domain_list}
    # Set Suite Variable  ${subdomain_list}
    # Set Test Variable  ${d1}  ${domain_list[0]}
    # Set Test Variable  ${sd1}  ${subdomain_list[0]}

    # ${highest_package}=  get_highest_license_pkg
    
    # ${resp}=  Account SignUp   simi  Dany  ${None}  ${d1}  ${sd1}  ${ConsMobilenum}    ${highest_package[0]}
    # Log  ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # ${resp}=  Account Activation  ${ConsMobilenum}  0
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # ${resp}=  Account Set Credential  ${ConsMobilenum}  ${NEW_PASSWORD12}  0
    # Should Be Equal As Strings    ${resp.status_code}    200
    # ${resp}=  Encrypted Provider Login  ${ConsMobilenum}  ${NEW_PASSWORD12}
    # Log  ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${ConsMobilenum}${\n}
    # Set Suite Variable  ${ConsMobilenum}
    # ${pid}=  get_acc_id  ${ConsMobilenum}
    # ${id}=  get_id  ${ConsMobilenum}
    # Set Suite Variable  ${id}
    # ${resp}=  Encrypted Provider Login  ${ConsMobilenum}  ${NEW_PASSWORD12}
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
    
    # ${resp}=   Get Service
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=    Get Locations
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=   Get Appointment Settings
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Run Keyword If  ${resp.json()['enableAppt']}==${bool[0]}   Enable Appointment

    # clear_service   ${ConsMobilenum}
    # clear_location  ${ConsMobilenum}
    # clear_customer   ${ConsMobilenum}

    # ${resp}=   Get Service
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=    Get Locations
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

   
    # ${resp}=   Get jaldeeIntegration Settings
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # ${resp1}=   Run Keyword If  ${resp.json()['walkinConsumerBecomesJdCons']}==${bool[0]}   Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${EMPTY}
    # Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.json()}
    # Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200
   
    # ${resp}=   Get jaldeeIntegration Settings
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # # Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[0]}
    # Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]} 

    # ${resp}=  Get Business Profile
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${pid}  ${resp.json()['id']} 


    
    # ${DAY1}=  db.get_date_by_timezone  ${tz}
    # ${list}=  Create List  1  2  3  4  5  6  7
    # ${ph1}=  Evaluate  ${ConsMobilenum}+15566122
    # ${ph2}=  Evaluate  ${ConsMobilenum}+25566122
    # ${views}=  Random Element    ${Views}
    # ${name1}=  FakerLibrary.name
    # ${name2}=  FakerLibrary.name
    # ${name3}=  FakerLibrary.name
    # ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
    # ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
    # ${emails1}=  Emails  ${name3}  Email  ${EmailProConsreshma}  ${views}
    # ${bs}=  FakerLibrary.bs
    # ${city}=   get_place
    # ${latti}=  get_latitude
    # ${longi}=  get_longitude
    # ${companySuffix}=  FakerLibrary.companySuffix
    # ${postcode}=  FakerLibrary.postcode
    # ${address}=  get_address
    # ${parking}   Random Element   ${parkingType}
    # ${24hours}    Random Element    ${bool}
    # ${desc}=   FakerLibrary.sentence
    # ${url}=   FakerLibrary.url
    # ${sTime}=  add_timezone_time  ${tz}  0  15  
    # ${eTime}=  add_timezone_time  ${tz}  0  45  
    # ${resp}=  Update Business Profile with Schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}   ${address}   ${ph_nos1}   ${ph_nos2}   ${emails1}   ${EMPTY}
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=  Get Business Profile
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=   Get Appointment Settings
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
    # Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}  

#     ${lid}=  Create Sample Location  
#     clear_appt_schedule   ${ConsMobilenum}
    
#     ${DAY1}=  db.get_date_by_timezone  ${tz}
#     ${DAY2}=  db.add_timezone_date  ${tz}  10        
#     ${list}=  Create List  1  2  3  4  5  6  7
#   # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
#     ${delta}=  FakerLibrary.Random Int  min=10  max=60
#     ${eTime1}=  add_two   ${sTime1}  ${delta}
#     ${SERVICE1}=   FakerLibrary.name
#     ${s_id}=  Create Sample Service  ${SERVICE1}
#     ${schedule_name}=  FakerLibrary.bs
#     ${parallel}=  FakerLibrary.Random Int  min=1  max=10
#     ${maxval}=  Convert To Integer   ${delta/2}
#     ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
#     ${bool1}=  Random Element  ${bool}
#     ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable  ${sch_id}  ${resp.json()}

#     ${resp}=  Get Appointment Schedule ById  ${sch_id}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

#     ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
#     Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
#     Set Test Variable   ${slot2}   ${resp.json()['availableSlots'][1]['time']}


#     ${resp}=  AddCustomer  ${MobilenumHi}  firstName=${f_Name}   lastName=${l_Name}
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable  ${cid}   ${resp.json()}
    
#     ${resp}=   Get Appointment Settings
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
#     Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}  

#     ${lid}=  Create Sample Location  
#     clear_appt_schedule   ${ConsMobilenum}
    
#     ${DAY1}=  db.get_date_by_timezone  ${tz}
#     ${DAY2}=  db.add_timezone_date  ${tz}  10        
#     ${list}=  Create List  1  2  3  4  5  6  7
#   # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
#     ${delta}=  FakerLibrary.Random Int  min=10  max=60
#     ${eTime1}=  add_two   ${sTime1}  ${delta}
#     ${SERVICE1}=   FakerLibrary.name
#     ${s_id}=  Create Sample Service  ${SERVICE1}
#     ${schedule_name}=  FakerLibrary.bs
#     ${parallel}=  FakerLibrary.Random Int  min=1  max=10
#     ${maxval}=  Convert To Integer   ${delta/2}
#     ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
#     ${bool1}=  Random Element  ${bool}
#     ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable  ${sch_id}  ${resp.json()}

#     ${resp}=  Get Appointment Schedule ById  ${sch_id}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

#     ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
#     Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
#     Set Test Variable   ${slot2}   ${resp.json()['availableSlots'][1]['time']}


   
#     ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
#     ${apptfor}=   Create List  ${apptfor1}

#     ${apptTime}=  db.get_tz_time_secs  ${tz} 
#     ${apptTakenTime}=  db.remove_secs   ${apptTime}
#     ${UpdatedTime}=  db.get_date_time_by_timezone  ${tz}
#     ${statusUpdatedTime}=   db.remove_date_time_secs   ${UpdatedTime}

#     ${cnote}=   FakerLibrary.word
#     ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
          
#     ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
#     Set Test Variable  ${apptid1}  ${apptid[0]}

#     ${resp}=  Get Appointment EncodedID   ${apptid1}
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${encId}=  Set Variable   ${resp.json()}

    
   
#     ${resp}=  Get Appointment By Id   ${apptid1}
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Should Be Equal As Strings  ${resp.json()['uid']}   ${apptid1}
#     Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id}
#     Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
#     Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[2]}
#     Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}   ${fname}
#     Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname}
#     Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot1}
#     Should Be Equal As Strings  ${resp.json()['appmtDate']}   ${DAY1}
#     Should Be Equal As Strings  ${resp.json()['appmtTime']}   ${slot1}
#     Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

#     ${reason}=  Random Element  ${cancelReason}
#     ${msg}=   FakerLibrary.word
#     ${resp}=    Provider Cancel Appointment  ${apptid1}  ${reason}  ${msg}  ${DAY1}
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     sleep   2s
#     ${resp}=  Get Appointment Status   ${apptid1}
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     # Should Be Equal As Strings  ${resp.json()[1]['appointmentStatus']}   ${apptStatus[4]}
#     Should Contain  "${resp.json()}"  ${apptStatus[4]}

#     ${cookie}  ${resp}=  Imageupload.conLogin  ${MobilenumHi}   ${PASSWORD1}
#     Log   ${resp.json()}
#     Should Be Equal As Strings   ${resp.status_code}    200

#     ${caption1}=  Fakerlibrary.sentence
#     ${filecap_dict1}=  Create Dictionary   file=${jpgfile}   caption=${caption1}
#     @{fileswithcaption}=  Create List   ${filecap_dict1}
    
   
#     ${resp}=  Imageupload.CAppmntcomm   ${cookie}   ${apptid1}  ${pid}  ${msg}  ${messageType[0]}  ${caption1}  ${EMPTY}  ${jpgfile}  
#     Log  ${resp}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=  Consumer Login  ${MobilenumHi}  ${PASSWORD1} 
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=  Get Consumer Communications
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Should Be Equal As Strings  ${resp.json()[1]['waitlistId']}         ${apptid1}
#     # Should Be Equal As Strings  ${resp.json()[1]['msg']}                ${msg}
#     # Should Be Equal As Strings  ${resp.json()[1]['receiver']['id']}     ${id}
#     Should Be Equal As Strings  ${resp.json()[1]['accountId']}          ${pid}    

# JD-TC-ShareFiles-2

#     [Documentation]  share file only one consumer

    # ${resp}=  Consumer SignUp Notification    Hisham   Muhammed   ${MobilenumHi}     ${countryCode}   email=${Emailhisham}
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # ${resp}=  Consumer Activation  ${Emailhisham}  1
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # ${resp}=  Consumer Set Credential Notification    ${Emailhisham}   ${PASSWORD1}   1   ${countryCode}
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # ${resp}=  Consumer Login Notification   ${MobilenumHi}   ${PASSWORD1}   ${countryCode}
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200

    # Append To File  ${EXECDIR}/data/TDD_Logs/consumernumbers.txt  ${MobilenumHi}${\n}

    # ${resp}=  Consumer Login  ${MobilenumHi}  ${PASSWORD1}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200  
    # Set Suite Variable  ${f_Name}  ${resp.json()['firstName']}
    # Set Suite Variable  ${l_Name}  ${resp.json()['lastName']}
    # Set Suite Variable  ${ph_no}  ${resp.json()['primaryPhoneNumber']}

    
    # ${resp}=  Consumer Logout
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200

    # ${domresp}=  Get BusinessDomainsConf
    # Log  ${domresp.json()}
    # Should Be Equal As Strings  ${domresp.status_code}  200
    # ${len}=  Get Length  ${domresp.json()}
    # ${domain_list}=  Create List
    # ${subdomain_list}=  Create List
    # FOR  ${domindex}  IN RANGE  ${len}
    #     Set Test Variable  ${d}  ${domresp.json()[${domindex}]['domain']}    
    #     Append To List  ${domain_list}    ${d} 
    #     Set Test Variable  ${sd}  ${domresp.json()[${domindex}]['subDomains'][0]['subDomain']}
    #     Append To List  ${subdomain_list}    ${sd} 
    # END
    # Log  ${domain_list}
    # Log  ${subdomain_list}
    # Set Suite Variable  ${domain_list}
    # Set Suite Variable  ${subdomain_list}
    # Set Test Variable  ${d1}  ${domain_list[0]}
    # Set Test Variable  ${sd1}  ${subdomain_list[0]}

    # ${highest_package}=  get_highest_license_pkg
    
    # ${resp}=  Account SignUp   simi  Dany  ${None}  ${d1}  ${sd1}  ${ConsMobilenum}    ${highest_package[0]}
    # Log  ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # ${resp}=  Account Activation  ${ConsMobilenum}  0
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # ${resp}=  Account Set Credential  ${ConsMobilenum}  ${NEW_PASSWORD12}  0
    # Should Be Equal As Strings    ${resp.status_code}    200
    # ${resp}=  Encrypted Provider Login  ${ConsMobilenum}  ${NEW_PASSWORD12}
    # Log  ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${ConsMobilenum}${\n}
    # Set Suite Variable  ${ConsMobilenum}
    # ${pid}=  get_acc_id  ${ConsMobilenum}
    # ${id1}=  get_id  ${ConsMobilenum}
    # Set Suite Variable  ${id1}
 
    # ${resp}=   Get Service
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=    Get Locations
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=   Get Appointment Settings
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Run Keyword If  ${resp.json()['enableAppt']}==${bool[0]}   Enable Appointment

    # clear_service   ${ConsMobilenum}
    # clear_location  ${ConsMobilenum}
    # clear_customer   ${ConsMobilenum}

    # ${resp}=   Get Service
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=    Get Locations
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

   
    # ${resp}=   Get jaldeeIntegration Settings
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # ${resp1}=   Run Keyword If  ${resp.json()['walkinConsumerBecomesJdCons']}==${bool[0]}   Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${EMPTY}
    # Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.json()}
    # Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200
   
    # ${resp}=   Get jaldeeIntegration Settings
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # # Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[0]}
    # Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]} 

    # ${resp}=  Get Business Profile
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${pid}  ${resp.json()['id']} 


    
    # ${DAY1}=  db.get_date_by_timezone  ${tz}
    # ${list}=  Create List  1  2  3  4  5  6  7
    # ${ph1}=  Evaluate  ${ConsMobilenum}+15566122
    # ${ph2}=  Evaluate  ${ConsMobilenum}+25566122
    # ${views}=  Random Element    ${Views}
    # ${name1}=  FakerLibrary.name
    # ${name2}=  FakerLibrary.name
    # ${name3}=  FakerLibrary.name
    # ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
    # ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
    # ${emails1}=  Emails  ${name3}  Email  ${EmailProConsreshma}  ${views}
    # ${bs}=  FakerLibrary.bs
    # ${city}=   get_place
    # ${latti}=  get_latitude
    # ${longi}=  get_longitude
    # ${companySuffix}=  FakerLibrary.companySuffix
    # ${postcode}=  FakerLibrary.postcode
    # ${address}=  get_address
    # ${parking}   Random Element   ${parkingType}
    # ${24hours}    Random Element    ${bool}
    # ${desc}=   FakerLibrary.sentence
    # ${url}=   FakerLibrary.url
    # ${sTime}=  add_timezone_time  ${tz}  0  15  
    # ${eTime}=  add_timezone_time  ${tz}  0  45  
    # ${resp}=  Update Business Profile with Schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}   ${address}   ${ph_nos1}   ${ph_nos2}   ${emails1}   ${EMPTY}
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=  Get Business Profile
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=   Get Appointment Settings
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
    # Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}  

   
    # ${resp}=  AddCustomer  ${MobilenumHi}  firstName=${f_Name}   lastName=${l_Name}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${cId4}   ${resp.json()}
    
    # # ${resp}=  AddCustomer  ${CUSERNAME5}  
    # # Log   ${resp.json()}
    # # Should Be Equal As Strings  ${resp.status_code}  200
    # # Set Suite Variable      ${cId4}        ${resp.json()}      

    # ${resp}=  GetCustomer  phoneNo-eq=${MobilenumHi} 
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${cid4}  ${resp.json()[0]['id']}
 

    # ${caption2}=  Fakerlibrary.Sentence
 
    # ${resp}=  db.getType   ${jpgfile}
    # Log  ${resp}
    
    # ${fileType2}=  Get From Dictionary       ${resp}    ${jpgfile}
    # Set Suite Variable    ${fileType2}
    # ${list1}=  Create Dictionary         owner=${id1}   fileName=${jpgfile}    fileSize=${filesize}     caption=${caption2}     fileType=${fileType2}   order=4
    # ${list}=   Create List     ${list1}

    # ${resp}=    Upload To Private Folder      publicFolder    ${id1}     ${list}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Log                                        ${resp.content}
    # Should Be Equal As Strings                 ${resp.status_code}                200
    # Should Be Equal As Strings                 ${resp.json()[0]['orderId']}      4
   
   
    # ${resp}=   Get by Criteria          owner-eq=${id1}
    # Log                                 ${resp.content}
    # Set Suite Variable     ${fileid}       ${resp.json()['${id1}']['files'][0]['id']} 

    # ${cookie}  ${resp}=   Imageupload.spLogin  ${ConsMobilenum}  ${NEW_PASSWORD12}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
   

    # ${fileid_list}=  Create List   ${fileid}

    # ${share}=       Create Dictionary     owner=${cid4}      ownerType=${ownerType[1]}
    # ${sharedto}=    Create List   ${share}
    
    # ${commessage}=  Fakerlibrary.Sentence
    # ${medium}=     Create Dictionary     email=${bool[1]}      pushNotification=${bool[1]}    
    # ${communication}=   Create Dictionary    medium=${medium}    commessage=${commessage}
    # ${resp}=    Imageupload.ShareFilesInJaldeeDrive     ${cookie}   ${sharedto}      ${fileid_list}    ${communication}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}     200

    # ${resp}=  Get provider communications
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200 


    # ${resp}=   ProviderLogout
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200

  
    # ${resp}=  Consumer Login  ${MobilenumHi}  ${PASSWORD1}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Get Consumer Communications
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200 
    
   
# JD-TC-AssignTeamTo Appointment and waitlist-1

#     [Documentation]  Assingn team to appointment. appmt okey
#     ${resp}=  Consumer SignUp Notification    Hisham   Muhammed   ${MobilenumHi}     ${countryCode}   email=${Emailhisham}
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${resp}=  Consumer Activation  ${Emailhisham}  1
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${resp}=  Consumer Set Credential Notification    ${Emailhisham}   ${PASSWORD1}   1   ${countryCode}
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${resp}=  Consumer Login Notification   ${MobilenumHi}   ${PASSWORD1}   ${countryCode}
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200

#     Append To File  ${EXECDIR}/data/TDD_Logs/consumernumbers.txt  ${MobilenumHi}${\n}

#     ${resp}=  Consumer Login  ${MobilenumHi}  ${PASSWORD1}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200  
#     Set Suite Variable  ${f_Name}  ${resp.json()['firstName']}
#     Set Suite Variable  ${l_Name}  ${resp.json()['lastName']}
#     Set Suite Variable  ${ph_no}  ${resp.json()['primaryPhoneNumber']}

    
#     ${resp}=  Consumer Logout
#     Log   ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200
    
    # ${iscorp_subdomains}=  get_iscorp_subdomains_with_maxpartysize  1
    #  Log  ${iscorp_subdomains}
    #  Set Test Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
    #  Set Test Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
    #  Set Suite Variable  ${sub_domain_id}   ${iscorp_subdomains[0]['subdomainId']}
    # #  ${firstname_A}=  FakerLibrary.first_name
    # #  Set Suite Variable  ${firstname_A}
    # #  ${lastname_A}=  FakerLibrary.last_name
    # #  Set Suite Variable  ${lastname_A}
    # #  ${PUSERNAME_E}=  Evaluate  ${PUSERNAME}+9908813
    #  ${highest_package}=  get_highest_license_pkg
    #  ${resp}=  Account SignUp  Simi  Dany  ${None}  ${domains}  ${sub_domains}  ${ConsMobilenum}    ${highest_package[0]}
    #  Log  ${resp.json()}
    #  Should Be Equal As Strings    ${resp.status_code}    200
    #  ${resp}=  Account Activation  ${ConsMobilenum}  0
    #  Log   ${resp.json()}
    #  Should Be Equal As Strings    ${resp.status_code}    200
    #  ${resp}=  Account Set Credential  ${ConsMobilenum}  ${PASSWORD}  0
    #  Should Be Equal As Strings    ${resp.status_code}    200
    #  ${resp}=  Encrypted Provider Login  ${ConsMobilenum}  ${PASSWORD}
    #  Log  ${resp.json()}
    #  Should Be Equal As Strings    ${resp.status_code}    200
    #  Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${ConsMobilenum}${\n}
    #  Set Suite Variable  ${ConsMobilenum}
    #  ${DAY1}=  db.get_date_by_timezone  ${tz}
    #  Set Suite Variable  ${DAY1}  ${DAY1}
    #  ${list}=  Create List  1  2  3  4  5  6  7
    #  Set Suite Variable  ${list}  ${list}
    #  ${ph1}=  Evaluate  ${ConsMobilenum}+1000000000
    #  ${ph2}=  Evaluate  ${ConsMobilenum}+2000000000
    #  ${views}=  Random Element    ${Views}
    #  ${name1}=  FakerLibrary.name
    #  ${name2}=  FakerLibrary.name
    #  ${name3}=  FakerLibrary.name
    #  ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
    #  ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
    #  ${emails1}=  Emails  ${name3}  Email  ${P_Email}183.${test_mail}  ${views}
    #  ${bs}=  FakerLibrary.bs
    #  ${city}=   get_place
    #  ${latti}=  get_latitude
    #  ${longi}=  get_longitude
    #  ${companySuffix}=  FakerLibrary.companySuffix
    #  ${postcode}=  FakerLibrary.postcode
    #  ${address}=  get_address
    #  ${parking}   Random Element   ${parkingType}
    #  ${24hours}    Random Element    ${bool}
    #  ${desc}=   FakerLibrary.sentence
    #  ${url}=   FakerLibrary.url
    #  ${sTime}=  add_timezone_time  ${tz}  0  15  
    #  Set Suite Variable   ${sTime}
    #  ${eTime}=  add_timezone_time  ${tz}  0  45  
    #  Set Suite Variable   ${eTime}
    #  ${resp}=  Update Business Profile With Schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}  ${EMPTY}
    #  Log  ${resp.json()}
    #  Should Be Equal As Strings    ${resp.status_code}    200

    #  ${fields}=   Get subDomain level Fields  ${domains}  ${sub_domains}
    #  Log  ${fields.json()}
    #  Should Be Equal As Strings    ${fields.status_code}   200

    #  ${virtual_fields}=  get_Subdomainfields  ${fields.json()}

    #  ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${sub_domains}
    #  Log  ${resp.json()}
    #  Should Be Equal As Strings  ${resp.status_code}  200

    #  ${resp}=  Get specializations Sub Domain  ${domains}  ${sub_domains}
    #  Should Be Equal As Strings    ${resp.status_code}   200

    #  ${spec}=  get_Specializations  ${resp.json()}
    #  ${resp}=  Update Specialization  ${spec}
    #  Log  ${resp.json()}
    #  Should Be Equal As Strings    ${resp.status_code}   200


    #  ${resp}=  Update Waitlist Settings  ${calc_mode[0]}   ${EMPTY}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
    #  Should Be Equal As Strings  ${resp.status_code}  200
     
    #  ${resp}=  Enable Waitlist
    #  Log   ${resp.json()}
    #  Should Be Equal As Strings  ${resp.status_code}  200


    # ${resp}=  Enable Appointment
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    
    #  sleep  1s
    #  ${resp}=  Get jaldeeIntegration Settings
    #  Log   ${resp.json()}
    #  Should Be Equal As Strings  ${resp.status_code}  200
    #  Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[0]} 

    #  ${resp}=  Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[1]}  ${boolean[0]}
    #  Log   ${resp.json()}
    #  Should Be Equal As Strings  ${resp.status_code}  200
    #  ${resp}=  Get jaldeeIntegration Settings
    #  Log   ${resp.json()}
    #  Should Be Equal As Strings  ${resp.status_code}  200
    #  Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}

    #  ${resp}=  View Waitlist Settings
    #  Log  ${resp.json()}
    #  Should Be Equal As Strings    ${resp.status_code}    200


    #  ${id}=  get_id  ${ConsMobilenum}
    #  Set Suite Variable  ${id}
    #  ${bs}=  FakerLibrary.bs
    #  Set Suite Variable  ${bs}

    #  ${resp}=  View Waitlist Settings
    #   Log  ${resp.json()}
    #   Should Be Equal As Strings    ${resp.status_code}    200

    #   ${resp}=  Run Keyword If  ${resp.json()['filterByDept']}==${bool[0]}   Toggle Department Enable
    #   Run Keyword If  '${resp}' != '${None}'   Log   ${resp.json()}
    #   Run Keyword If  '${resp}' != '${None}'   Should Be Equal As Strings  ${resp.status_code}  200
    #  sleep  2s
    #  ${resp}=  Get Departments
    #  Log   ${resp.json()}
    #  Should Be Equal As Strings  ${resp.status_code}  200
    #  Set Suite Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}
    
    # ${resp}=    Get Locations
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable   ${lid}   ${resp.json()[0]['id']}

    # ${resp}=   Get License UsageInfo 
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
   
    # sleep  2s
    # ${resp}=  Get Departments
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}
    
    # ${DAY1}=  db.get_date_by_timezone  ${tz}
    # ${DAY2}=  db.add_timezone_date  ${tz}  10        
    # ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    # ${delta}=  FakerLibrary.Random Int  min=10  max=60
    # ${eTime1}=  add_two   ${sTime1}  ${delta}
    # # ${SERVICE1}=  FakerLibrary.word
    # # ${s_id}=  Create Sample Service  ${SERVICE1}
    # # Set Suite Variable   ${s_id}
    #   ${description}=  FakerLibrary.sentence

    # ${ser_durtn}=   Random Int   min=2   max=10
    # ${ser_amount}=   Random Int   min=200   max=500
    # ${ser_amount}=  Convert To Number  ${ser_amount}  1
    # Set Suite Variable    ${ser_amount} 
    # ${min_pre}=   Random Int   min=10   max=50
    # ${min_pre}=  Convert To Number  ${min_pre}  1
    # Set Suite Variable    ${min_pre} 
    # ${notify}    Random Element     ['True','False']
    # ${notifytype}    Random Element     ['none','pushMsg','email']

    # ${SERVICE5}=   FakerLibrary.name
    # ${resp}=  Create Service  ${SERVICE5}  ${description}   ${ser_durtn}  ${status[0]}  ${btype}  ${notify}   ${notifytype}  ${EMPTY}  ${ser_amount}  ${bool[0]}  ${bool[0]}   department=${dep_id}
    # Should Be Equal As Strings  ${resp.status_code}  200 
    # Set Suite Variable    ${s_id}  ${resp.json()}

    # ${schedule_name}=  FakerLibrary.bs
    # ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    # ${maxval}=  Convert To Integer   ${delta/2}
    # ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    # ${bool1}=  Random Element  ${bool}
    # ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${sch_id}  ${resp.json()}

    # ${resp}=  Get Appointment Schedule ById  ${sch_id}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

    # ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
    # Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    # ${resp}=  AddCustomer  ${MobilenumHi}  firstName=${f_Name}   lastName=${l_Name}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${cid}   ${resp.json()}
    
   
    # ${resp}=  GetCustomer  phoneNo-eq=${MobilenumHi} 
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${cid}  ${resp.json()[0]['id']}

    # ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    # ${apptfor}=   Create List  ${apptfor1}
    
    # ${cnote}=   FakerLibrary.word
    # ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
          
    # ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    # Set Suite Variable  ${apptid1}  ${apptid[0]}

    # ${resp}=  Get Appointment EncodedID   ${apptid1}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # ${encId}=  Set Variable   ${resp.json()}

    # ${resp}=  Get Appointment By Id   ${apptid1}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    #  ${q_name}=    FakerLibrary.name
    # # ${list2}=  Create List   1  2  3  4  5  6  7
    # ${strt_time}=   add_timezone_time  ${tz}  1  00  
    # ${end_time}=    add_timezone_time  ${tz}  2  00   
    # ${parallel}=   FakerLibrary.Random Int  min=1   max=10 
    # ${capacity}=   FakerLibrary.Random Int  min=1   max=10 
    # ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}   ${parallel}   ${capacity}    ${lid}  ${s_id}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${q_id}   ${resp.json()}

    # # ${resp}=  AddCustomer  ${CUSERNAME1}
    # # Log   ${resp.json()}
    # # Should Be Equal As Strings  ${resp.status_code}  200
    # # Set Test Variable  ${cid}  ${resp.json()}

    # ${desc}=   FakerLibrary.word
    # ${resp}=  Add To Waitlist  ${cid}  ${s_id}  ${q_id}  ${DAY1}  ${desc}  ${bool[1]}  ${cid} 
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # ${wid}=  Get Dictionary Values  ${resp.json()}
    # Set Suite Variable  ${wid}  ${wid[0]}

    # ${resp}=  Get Waitlist By Id  ${wid} 
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  View Waitlist Settings
    # Log  ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200



    # ${USERNAME1}=  Evaluate  ${ConsMobilenum}+144557005
    # Set Suite Variable  ${USERNAME1}
    # ${firstname}=  FakerLibrary.name
    # ${lastname}=  FakerLibrary.last_name
    # ${dob}=  FakerLibrary.Date
    # # ${pin}=  get_pincode
    #  # ${resp}=  Get LocationsByPincode     ${pin}
    #  FOR    ${i}    IN RANGE    3
    #     ${pin}=  get_pincode
    #     ${kwstatus}  ${resp} =  Run Keyword And Ignore Error  Get LocationsByPincode  ${pin}
    #     IF    '${kwstatus}' == 'FAIL'
    #             Continue For Loop
    #     ELSE IF    '${kwstatus}' == 'PASS'
    #             Exit For Loop
    #     END
    #  END
    # Log  ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200 

    # ${whpnum}=  Evaluate  ${ConsMobilenum}+77480
    # ${tlgnum}=  Evaluate  ${ConsMobilenum}+65876

    # ${resp}=  Create User  Muhammad  Hisham  ${dob}  ${Genderlist[0]}   ${emailsimi}   ${userType[0]}  ${pin}  ${countryCodes[0]}  ${MobilenumHi122}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${countryCodes[0]}  ${MobilenumHi122}  ${countryCodes[0]}  ${MobilenumHi122}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${u_id1}  ${resp.json()}

    # ${resp}=  Get User
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
   
    # ${USERNAME2}=  Evaluate  ${ConsMobilenum}+144556874
    # Set Suite Variable  ${USERNAME2}
    # clear_users  ${USERNAME2}
    # ${firstname1}=  FakerLibrary.name
    # ${lastname1}=  FakerLibrary.last_name
    # ${dob1}=  FakerLibrary.Date
    # ${pin}=  get_pincode
    
    # ${resp}=  Create User  Reshma  Mohan  ${dob1}  ${Genderlist[0]}    ${EmailProConsreshma}    ${userType[0]}  ${pin}  ${countryCodes[0]}  ${MobilenumRIA}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${u_id2}  ${resp.json()}
    
    # ${USERNAME3}=  Evaluate  ${ConsMobilenum}+144557893
    # Set Suite Variable  ${USERNAME3}
    # clear_users  ${USERNAME3}
    # ${firstname2}=  FakerLibrary.name
    # ${lastname2}=  FakerLibrary.last_name
    # ${dob2}=  FakerLibrary.Date
    # ${pin}=  get_pincode
   
    # ${resp}=  Create User  Sam  roy  ${dob2}  ${Genderlist[0]}  ${P_Email}${USERNAME3}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[0]}  ${USERNAME3}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${u_id3}  ${resp.json()}

    

    # ${team_name}=  FakerLibrary.name
    # ${team_size}=  Random Int  min=10  max=50
    # ${desc}=   FakerLibrary.sentence

    # ${resp}=  Create Team For User  ${team_name}  ${team_size}  ${desc}
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # Set Suite Variable  ${t_id1}  ${resp.json()}

    # ${user_ids}=  Create List  ${u_id1}  ${u_id2}

    # ${resp}=   Assign Team To User  ${user_ids}  ${t_id1}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=   Assign Team To Appointment  ${apptid1}  ${t_id1}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  SendProviderResetMail   ${MobilenumHi122}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # @{resp}=  ResetProviderPassword  ${MobilenumHi122}  ${PASSWORDuser1}  2
    # Should Be Equal As Strings  ${resp[0].status_code}  200
    # Should Be Equal As Strings  ${resp[1].status_code}  200

    # ${resp}=  Encrypted Provider Login  ${MobilenumHi122}  ${PASSWORDuser1}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Get Appointments Today  team-eq=id::${t_id1}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # Should Be Equal As Strings  ${resp.json()[0]['uid']}         ${apptid1}
    # Should Be Equal As Strings  ${resp.json()[0]['apptStatus']}  ${apptStatus[2]}
    # Should Be Equal As Strings  ${resp.json()[0]['teamId']}          ${t_id1}

    # ${resp}=  Get Waitlist Today    team-eq=id::${t_id1}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200


    # ${resp}=  SendProviderResetMail   ${MobilenumRIA}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # @{resp}=  ResetProviderPassword  ${MobilenumRIA}  ${PASSWORDuser2}  2
    # Should Be Equal As Strings  ${resp[0].status_code}  200
    # Should Be Equal As Strings  ${resp[1].status_code}  200

    # ${resp}=  Encrypted Provider Login  ${MobilenumRIA}  ${PASSWORDuser2}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Get Appointments Today   team-eq=id::${t_id1}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    
    # Should Be Equal As Strings  ${resp.json()[0]['uid']}         ${apptid1}
    # Should Be Equal As Strings  ${resp.json()[0]['apptStatus']}  ${apptStatus[2]}
    # Should Be Equal As Strings  ${resp.json()[0]['teamId']}          ${t_id1}


    # ${resp}=  Get Waitlist Today    team-eq=id::${t_id1}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}         ${wid}
    # Should Be Equal As Strings  ${resp.json()[0]['waitlistStatus']}  ${wl_status[1]}
    # Should Be Equal As Strings  ${resp.json()[0]['teamId']}          ${t_id1}


    

JD-TC-DonationPayment, order item by cosumer , order mass communication-1
    [Documentation]   Consumer do payment of a donation bill

    ${resp}=  Consumer SignUp Notification    Hisham   Muhammed   ${MobilenumHi}     ${countryCode}   email=${Emailhisham}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Activation  ${Emailhisham}  1
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Set Credential Notification    ${Emailhisham}   ${PASSWORD1}   1   ${countryCode}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Login Notification   ${MobilenumHi}   ${PASSWORD1}   ${countryCode}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    Append To File  ${EXECDIR}/data/TDD_Logs/consumernumbers.txt  ${MobilenumHi}${\n}

    ${resp}=  Consumer Login  ${MobilenumHi}  ${PASSWORD1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Suite Variable  ${f_Name}  ${resp.json()['firstName']}
    Set Suite Variable  ${l_Name}  ${resp.json()['lastName']}
    Set Suite Variable  ${ph_no}  ${resp.json()['primaryPhoneNumber']}
    Set Suite Variable  ${c14_UName}   ${resp.json()['userName']}
    Set Suite Variable  ${c14_Uid}     ${resp.json()['id']}


    
    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

     ${iscorp_subdomains}=  get_iscorp_subdomains_with_maxpartysize  1
     Log  ${iscorp_subdomains}
     Set Test Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
     Set Test Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
     Set Suite Variable  ${sub_domain_id}   ${iscorp_subdomains[0]['subdomainId']}
    #  ${firstname_A}=  FakerLibrary.first_name
    #  Set Suite Variable  ${firstname_A}
    #  ${lastname_A}=  FakerLibrary.last_name
    #  Set Suite Variable  ${lastname_A}
    #  ${PUSERNAME_E}=  Evaluate  ${PUSERNAME}+9908813
     ${highest_package}=  get_highest_license_pkg
     ${resp}=  Account SignUp  Simi  Dany  ${None}  ${domains}  ${sub_domains}  ${ConsMobilenum}    ${highest_package[0]}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Account Activation  ${ConsMobilenum}   0
     Log   ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Account Set Credential  ${ConsMobilenum}  ${PASSWORD}  0
     Should Be Equal As Strings    ${resp.status_code}    200

     ${resp}=  Encrypted Provider Login  ${ConsMobilenum}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${ConsMobilenum}${\n}
     Set Suite Variable  ${ConsMobilenum}
     ${DAY1}=  db.get_date_by_timezone  ${tz}

     Set Suite Variable  ${DAY1}  ${DAY1}
     ${list}=  Create List  1  2  3  4  5  6  7
     Set Suite Variable  ${list}  ${list}
     ${ph1}=  Evaluate  ${ConsMobilenum}+1000000000
     ${ph2}=  Evaluate  ${ConsMobilenum}+2000000000
     ${views}=  Random Element    ${Views}
     ${name1}=  FakerLibrary.name
     ${name2}=  FakerLibrary.name
     ${name3}=  FakerLibrary.name
     ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
     ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
     ${emails1}=  Emails  ${name3}  Email  ${P_Email}183.${test_mail}  ${views}
     ${bs}=  FakerLibrary.bs
     ${companySuffix}=  FakerLibrary.companySuffix
     # ${city}=   get_place
     # ${latti}=  get_latitude
     # ${longi}=  get_longitude
     # ${postcode}=  FakerLibrary.postcode
     # ${address}=  get_address
     ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
     ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
     Set Suite Variable  ${tz}
     ${parking}   Random Element   ${parkingType}
     ${24hours}    Random Element    ${bool}
     ${desc}=   FakerLibrary.sentence
     ${url}=   FakerLibrary.url
     ${sTime}=  add_timezone_time  ${tz}  0  15  
     Set Suite Variable   ${sTime}
     ${eTime}=  add_timezone_time  ${tz}  0  45  
     Set Suite Variable   ${eTime}
     ${resp}=  Update Business Profile With Schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}  ${EMPTY}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200

     ${fields}=   Get subDomain level Fields  ${domains}  ${sub_domains}
     Log  ${fields.json()}
     Should Be Equal As Strings    ${fields.status_code}   200

     ${virtual_fields}=  get_Subdomainfields  ${fields.json()}

     ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${sub_domains}
     Log  ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200

     ${resp}=  Get specializations Sub Domain  ${domains}  ${sub_domains}
     Should Be Equal As Strings    ${resp.status_code}   200

     ${spec}=  get_Specializations  ${resp.json()}
     ${resp}=  Update Specialization  ${spec}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}   200


     ${resp}=  Update Waitlist Settings  ${calc_mode[0]}   ${EMPTY}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
     Should Be Equal As Strings  ${resp.status_code}  200
     
     ${resp}=  Enable Waitlist
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  Enable Appointment
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
     sleep  1s
     ${resp}=  Get jaldeeIntegration Settings
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[0]} 

     ${resp}=  Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[1]}  ${boolean[0]}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     ${resp}=  Get jaldeeIntegration Settings
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}

     ${resp}=  View Waitlist Settings
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200


     ${id}=  get_id  ${ConsMobilenum}
     Set Suite Variable  ${id}
     ${bs}=  FakerLibrary.bs
     Set Suite Variable  ${bs}

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
    Set Suite Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}
    
    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${lid}   ${resp.json()[0]['id']}

    ${resp}=   Get License UsageInfo 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    sleep  2s
    ${resp}=  Get Departments
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}
    
    
        # ${resp}=  Encrypted Provider Login  ${PUSERNAME51}  ${PASSWORD}
        # Log  ${resp.json()}
        # Should Be Equal As Strings    ${resp.status_code}    200
        # delete_donation_service  ${PUSERNAME51}
        # clear_service   ${PUSERNAME51}
        # clear_queue      ${PUSERNAME51}
        # clear_location   ${PUSERNAME51}

        # ${pid}=  get_acc_id  ${PUSERNAME51}
        # Set Suite Variable  ${pid}
        
        ${resp}=  Get Account Settings
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        IF  ${resp.json()['onlinePayment']}==${bool[0]}   
        ${resp}=   Enable Disable Online Payment   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

        ${resp}=  Get Account Settings
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
         ${resp}=   Billable
        ${resp}=   Create Sample Location
        Set Suite Variable    ${loc_id1}    ${resp} 

        ${resp}=   Get Location ById  ${loc_id1}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']} 
        ${description}=  FakerLibrary.sentence
        ${min_don_amt1}=   Random Int   min=100   max=500
        ${mod}=  Evaluate  ${min_don_amt1}%${multiples[0]}
        ${min_don_amt}=  Evaluate  ${min_don_amt1}-${mod}
        ${max_don_amt1}=   Random Int   min=5000   max=10000
        ${mod1}=  Evaluate  ${max_don_amt1}%${multiples[0]}
        ${max_don_amt}=  Evaluate  ${max_don_amt1}-${mod1}
        ${min_don_amt}=  Convert To Number  ${min_don_amt}  1
        ${max_don_amt}=  Convert To Number  ${max_don_amt}  1
        ${service_duration}=   Random Int   min=10   max=50
        ${total_amnt}=   Random Int   min=100   max=500
        ${total_amnt}=  Convert To Number  ${total_amnt}   1
        ${SERV}=  FakerLibrary.word
        ${s_id}=  Create Sample Service  ${SERV}
        Set Suite Variable   ${s_id}
        ${resp}=  Create Donation Service   haircutting  ${description}   ${service_duration}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${total_amnt}   ${bool[0]}   ${bool[0]}  ${service_type[0]}  ${min_don_amt}  ${max_don_amt}  ${multiples[0]}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200  
        Set Suite Variable  ${sid1}  ${resp.json()}

    ${resp}=  Consumer Login  ${MobilenumHi}  ${PASSWORD1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Suite Variable  ${f_Name}  ${resp.json()['firstName']}
    Set Suite Variable  ${l_Name}  ${resp.json()['lastName']}
    Set Suite Variable  ${ph_no}  ${resp.json()['primaryPhoneNumber']}

        ${con_id}=  get_id  ${MobilenumHi}
        Set Suite Variable  ${con_id}
        ${acc_id}=  get_acc_id  ${ConsMobilenum}
        Set Suite Variable  ${acc_id}
        ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
        Set Suite Variable  ${CUR_DAY}
        # ${don_amt}=  Evaluate  ${min_don_amt}*${multiples[0]}
        # ${don_amt_float}=  twodigitfloat  ${don_amt}
        ${don_amt}=   Random Int   min=1000   max=4000
        ${mod}=  Evaluate  ${don_amt}%${multiples[0]}
        ${don_amt}=  Evaluate  ${don_amt}-${mod}
        ${don_amt}=  Convert To Number  ${don_amt}  1
        ${don_amt_float}=  twodigitfloat  ${don_amt}

        Set Suite Variable  ${don_amt}
        ${resp}=  Donation By Consumer  ${con_id}  ${sid1}  ${loc_id1}  ${don_amt}  ${f_Name}  ${l_Name}  ${EMPTY}  ${EMPTY}  ${EMPTY}  ${acc_id}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200  
        
        ${don_id}=  Get Dictionary Values  ${resp.json()}
        Set Suite Variable  ${don_id}  ${don_id[0]}
        ${resp}=  Get Consumer Donation By Id  ${don_id}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200 
        Verify Response  ${resp}    uid=${don_id}   date=${CUR_DAY}  billPaymentStatus=${paymentStatus[0]}  donationAmount=${don_amt}
        Should Be Equal As Strings  ${resp.json()['consumer']['id']}  ${con_id}
        Should Be Equal As Strings  ${resp.json()['service']['id']}  ${sid1}
        Should Be Equal As Strings  ${resp.json()['location']['id']}  ${loc_id1}

        ${resp}=  Get Bill By consumer  ${don_id}  ${acc_id}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        
        ${resp}=  Make payment Consumer Mock  ${acc_id}  ${don_amt}  ${purpose[5]}  ${don_id}  ${sid1}  ${bool[0]}   ${bool[1]}  ${con_id}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable   ${payref}   ${resp.json()['paymentRefId']}

        ${resp}=  Get Payment Details By UUId    ${don_id}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${mock_id}  ${resp.json()[0]['id']}
        # Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}  ${don_id}
        # Should Be Equal As Strings  ${resp.json()[0]['status']}  ${cupnpaymentStatus[4]}  
        # Should Be Equal As Strings  ${resp.json()[0]['acceptPaymentBy']}  ${pay_mode_selfpay}
        # Should Be Equal As Strings  ${resp.json()[0]['amount']}  ${don_amt}  
        # Should Be Equal As Strings  ${resp.json()[0]['custId']}  ${con_id}   
        # Should Be Equal As Strings  ${resp.json()[0]['paymentMode']}  ${payment_modes[2]}  
        # Should Be Equal As Strings  ${resp.json()[0]['accountId']}  ${acc_id}  
        # # Should Be Equal As Strings  ${resp.json()[0]['paymentPurpose']}  ${purpose[5]}  
        # Should Be Equal As Strings  ${resp.json()[0]['paymentGateway']}  RAZORPAY  

        Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}  ${don_id}
        Should Be Equal As Strings  ${resp.json()[0]['status']}  ${cupnpaymentStatus[0]}  
        Should Be Equal As Strings  ${resp.json()[0]['acceptPaymentBy']}  ${pay_mode_selfpay}
        Should Be Equal As Strings  ${resp.json()[0]['amount']}  ${don_amt} 
        Should Be Equal As Strings  ${resp.json()[0]['custId']}  ${con_id}   
        Should Be Equal As Strings  ${resp.json()[0]['paymentMode']}  ${payment_modes[5]}  
        Should Be Equal As Strings  ${resp.json()[0]['accountId']}  ${acc_id}  
        # Should Be Equal As Strings  ${resp.json()[1]['paymentPurpose']}  ${purpose[5]}  
        Should Be Equal As Strings  ${resp.json()[0]['paymentGateway']}  RAZORPAY  

        ${resp}=  Get Individual Payment Records  ${mock_id}
        Log  *${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()['ynwUuid']}  ${don_id}
        Should Be Equal As Strings  ${resp.json()['status']}  ${cupnpaymentStatus[0]}  
        Should Be Equal As Strings  ${resp.json()['acceptPaymentBy']}  ${pay_mode_selfpay}
        Should Be Equal As Strings  ${resp.json()['amount']}  ${don_amt}
        Should Be Equal As Strings  ${resp.json()['custId']}  ${con_id}   
        Should Be Equal As Strings  ${resp.json()['paymentMode']}  ${payment_modes[5]}  
        Should Be Equal As Strings  ${resp.json()['accountId']}  ${acc_id}  
        # Should Be Equal As Strings  ${resp.json()['paymentPurpose']}  ${purpose[5]}  
        Should Be Equal As Strings  ${resp.json()['paymentGateway']}  RAZORPAY 

        ${resp}=  Get Payment Details  paymentRefId-eq=${payref}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}  ${don_id}
        Should Be Equal As Strings  ${resp.json()[0]['status']}  ${cupnpaymentStatus[0]}  
        Should Be Equal As Strings  ${resp.json()[0]['acceptPaymentBy']}  ${pay_mode_selfpay}
        Should Be Equal As Strings  ${resp.json()[0]['amount']}  ${don_amt}  
        Should Be Equal As Strings  ${resp.json()[0]['custId']}  ${con_id}   
        Should Be Equal As Strings  ${resp.json()[0]['paymentMode']}  ${payment_modes[5]}  
        Should Be Equal As Strings  ${resp.json()[0]['accountId']}  ${acc_id}  
        # Should Be Equal As Strings  ${resp.json()[0]['paymentPurpose']}  ${purpose[5]}  
        Should Be Equal As Strings  ${resp.json()[0]['paymentGateway']}  RAZORPAY 

        ${resp}=  Get Consumer Donation By Id  ${don_id}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200 
        Verify Response  ${resp}    uid=${don_id}   date=${CUR_DAY}  billPaymentStatus=${paymentStatus[2]}  donationAmount=${don_amt}
        Should Be Equal As Strings  ${resp.json()['consumer']['id']}  ${con_id}
        Should Be Equal As Strings  ${resp.json()['service']['id']}  ${sid1}
        Should Be Equal As Strings  ${resp.json()['location']['id']}  ${loc_id1}

        ${resp}=   Consumer Logout         
        Should Be Equal As Strings    ${resp.status_code}   200

# ........................ order by consumer ................................  okey
    ${resp}=  Encrypted Provider Login  ${ConsMobilenum}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${ConsMobilenum}${\n}
     Set Suite Variable  ${ConsMobilenum}
    Set Test Variable  ${pid}  ${resp.json()['id']}
    
    ${accId}=  get_acc_id  ${ConsMobilenum}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    Set Test Variable  ${email_id}  ${firstname}${ConsMobilenum}.${test_mail}

    ${resp}=  Update Email   ${pid}   ${firstname}   ${lastname}   ${EmailProConsreshma}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Order Settings by account id
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableOrder']}==${bool[0]}   Enable Order Settings

    ${displayName1}=   FakerLibrary.name 
    ${shortDesc1}=  FakerLibrary.Sentence   nb_words=2  
    ${itemDesc1}=  FakerLibrary.Sentence   nb_words=3   
    ${price1}=  Random Int  min=50   max=300 
    ${price1float}=  twodigitfloat  ${price1}

    ${itemName1}=   FakerLibrary.name  

    ${itemNameInLocal1}=  FakerLibrary.Sentence   nb_words=2  
  
    ${promoPrice1}=  Random Int  min=10   max=${price1} 

    ${promoPrice1float}=  twodigitfloat  ${promoPrice1}

    ${promoPrcnt1}=   Evaluate    random.uniform(0.0,80)
    ${promotionalPrcnt1}=  twodigitfloat  ${promoPrcnt1}

    ${note1}=  FakerLibrary.Sentence   

    ${itemCode1}=   FakerLibrary.word 

    ${promoLabel1}=   FakerLibrary.word 

    ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[1]}    ${itemName1}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode1}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${item_id1}  ${resp.json()}

    ${startDate}=  db.get_date_by_timezone  ${tz}
    ${endDate}=  db.add_timezone_date  ${tz}  10        

    ${startDate1}=  db.add_timezone_date  ${tz}  11  
    ${endDate1}=  db.add_timezone_date  ${tz}  15        

    ${noOfOccurance}=  Random Int  min=0   max=0

    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${eTime1}=  add_timezone_time  ${tz}  3  30     
    ${list}=  Create List  1  2  3  4  5  6  7
  
    ${deliveryCharge}=  Random Int  min=1   max=100
 
    ${Title}=  FakerLibrary.Sentence   nb_words=2 
    ${Text}=  FakerLibrary.Sentence   nb_words=4

    ${minQuantity}=  Random Int  min=1   max=30

    ${maxQuantity}=  Random Int  min=${minQuantity}   max=50

    ${catalogName}=   FakerLibrary.name  

    ${catalogDesc}=   FakerLibrary.name 

    ${cancelationPolicy}=  FakerLibrary.Sentence   nb_words=5

    ${terminator}=  Create Dictionary  endDate=${endDate}  noOfOccurance=${noOfOccurance}
    ${terminator1}=  Create Dictionary  endDate=${endDate1}  noOfOccurance=${noOfOccurance}

    ${timeSlots1}=  Create Dictionary  sTime=${sTime1}   eTime=${eTime1}
    ${timeSlots}=  Create List  ${timeSlots1}
    ${catalogSchedule}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate}   terminator=${terminator}   timeSlots=${timeSlots}
    ${pickupSchedule}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate1}   terminator=${terminator1}   timeSlots=${timeSlots}

    ${pickUp}=  Create Dictionary  orderPickUp=${boolean[1]}   pickUpSchedule=${pickupSchedule}   pickUpOtpVerification=${boolean[1]}   pickUpScheduledAllowed=${boolean[1]}   pickUpAsapAllowed=${boolean[1]}

    ${homeDelivery}=  Create Dictionary  homeDelivery=${boolean[1]}   deliverySchedule=${pickupSchedule}   deliveryOtpVerification=${boolean[1]}   deliveryRadius=5   scheduledHomeDeliveryAllowed=${boolean[1]}   asapHomeDeliveryAllowed=${boolean[1]}   deliveryCharge=${deliveryCharge}

    ${preInfo}=  Create Dictionary  preInfoEnabled=${boolean[1]}   preInfoTitle=${Title}   preInfoText=${Text}   
 
    ${postInfo}=  Create Dictionary  postInfoEnabled=${boolean[1]}   postInfoTitle=${Title}   postInfoText=${Text}   

    ${orderStatuses}=  Create List  ${orderStatuses[0]}  ${orderStatuses[1]}   ${orderStatuses[2]}   ${orderStatuses[3]}  ${orderStatuses[11]}   ${orderStatuses[12]}
    
    ${item1_Id}=  Create Dictionary  itemId=${item_id1}   
    ${catalogItem1}=  Create Dictionary  item=${item1_Id}    minQuantity=${minQuantity}   maxQuantity=${maxQuantity}  
    ${catalogItem}=  Create List   ${catalogItem1}
    
    Set Test Variable  ${orderType}       ${OrderTypes[0]}
    Set Test Variable  ${catalogStatus}   ${catalogStatus[0]}
    Set Test Variable  ${paymentType}     ${AdvancedPaymentType[0]}

    ${advanceAmount}=  Random Int  min=1   max=1000
   
    ${far}=  Random Int  min=14  max=14
   
    ${soon}=  Random Int  min=1   max=1
   
    Set Test Variable  ${minNumberItem}   1

    Set Test Variable  ${maxNumberItem}   5


    ${resp}=  Create Catalog For ShoppingCart   ${catalogName}  ${catalogDesc}   ${catalogSchedule}   ${orderType}   ${paymentType}   ${orderStatuses}   ${catalogItem}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${CatalogId1}   ${resp.json()}

    ${resp}=  Get Order Catalog    ${CatalogId1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Consumer Login  ${MobilenumHi}  ${PASSWORD1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Suite Variable  ${f_Name}  ${resp.json()['firstName']}
    Set Suite Variable  ${l_Name}  ${resp.json()['lastName']}
    Set Suite Variable  ${ph_no}  ${resp.json()['primaryPhoneNumber']}

    ${cookie}  ${resp}=  Imageupload.conLogin  ${MobilenumHi}   ${PASSWORD1}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200
    
    ${DAY1}=  db.add_timezone_date  ${tz}  ${OtpPurpose['Authentication']}  
    # ${C_firstName}=   FakerLibrary.first_name 
    # ${C_lastName}=   FakerLibrary.name 
     ${C_num1}    Random Int  min=123456   max=999999
    # ${CUSERPH}=  Evaluate  ${CUSERNAME}+${C_num1}
    # Set Test Variable  ${C_email}  ${C_firstName}${CUSERPH}.${test_mail}
    ${homeDeliveryAddress}=   FakerLibrary.name 
    ${city}=  FakerLibrary.city
    ${landMark}=  FakerLibrary.Sentence   nb_words=2 
    ${address}=  Create Dictionary   phoneNumber=${MobilenumHi}    firstName=${f_Name}   lastName=${l_Name}   email=${Emailhisham}    address=${homeDeliveryAddress}   city=${city}   postalCode=${C_num1}    landMark=${landMark}   countryCode=${countryCodes[0]}
    Set Suite Variable  ${address}

    ${country_code}    Generate random string    2    0123456789
    ${country_code}    Convert To Integer  ${country_code}
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity}   max=${maxQuantity}
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERNAME20}.${test_mail}
    ${EMPTY_List}=  Create List
    Set Suite Variable  ${EMPTY_List}

    ${resp}=   Create Order For HomeDelivery   ${cookie}   ${accId}    ${self}    ${CatalogId1}   ${bool[1]}    ${address}    ${sTime1}    ${eTime1}   ${DAY1}    ${CUSERNAME20}    ${email}  ${countryCodes[1]}  ${EMPTY_List}   ${item_id1}    ${item_quantity1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${orderid1}  ${orderid[0]}

    ${resp}=   Get Order By Id  ${accId}  ${orderid1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
   ${resp}=   Consumer Logout         
    Should Be Equal As Strings    ${resp.status_code}   200

# ......................................oder mass communication.....................
JD-TC-Order_MassCommunication-1
#     [Documentation]    Place an order By Provider for pickup (Both ShoppingCart and ShoppingList).
    
#     ${resp}=  Consumer SignUp Notification    Hisham   Muhammed   ${MobilenumHi}     ${countryCode}   email=${Emailhisham}
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${resp}=  Consumer Activation  ${Emailhisham}  1
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${resp}=  Consumer Set Credential Notification    ${Emailhisham}   ${PASSWORD1}   1   ${countryCode}
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${resp}=  Consumer Login Notification   ${MobilenumHi}   ${PASSWORD1}   ${countryCode}
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200

#     Append To File  ${EXECDIR}/data/TDD_Logs/consumernumbers.txt  ${MobilenumHi}${\n}

    ${resp}=  Consumer Login  ${MobilenumHi}  ${PASSWORD1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Suite Variable  ${f_Name}  ${resp.json()['firstName']}
    Set Suite Variable  ${l_Name}  ${resp.json()['lastName']}
    Set Suite Variable  ${ph_no}  ${resp.json()['primaryPhoneNumber']}
    Set Suite Variable  ${c14_UName}   ${resp.json()['userName']}
    Set Suite Variable  ${c14_Uid}     ${resp.json()['id']}

    

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer SignUp Notification   Ram   sam   ${MobilenumRIA}     ${countryCode}   email=${EmailRaigan}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Activation  ${EmailRaigan}  1
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Set Credential Notification    ${EmailRaigan}   ${PASSWORDorder}   1   ${countryCode}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Login Notification   ${MobilenumRIA}   ${PASSWORDorder}   ${countryCode}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    Append To File  ${EXECDIR}/data/TDD_Logs/consumernumbers.txt  ${MobilenumRIA}${\n}

    ${resp}=  Consumer Login  ${MobilenumRIA}  ${PASSWORDorder}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Suite Variable  ${f_Name}  ${resp.json()['firstName']}
    Set Suite Variable  ${l_Name}  ${resp.json()['lastName']}
    Set Suite Variable  ${ph_no}  ${resp.json()['primaryPhoneNumber']}
    Set Suite Variable  ${c15_UName}   ${resp.json()['userName']}
    Set Suite Variable  ${c15_Uid}     ${resp.json()['id']}



    
    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200


    #  ${iscorp_subdomains}=  get_iscorp_subdomains_with_maxpartysize  1
    #  Log  ${iscorp_subdomains}
    #  Set Test Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
    #  Set Test Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
    #  Set Suite Variable  ${sub_domain_id}   ${iscorp_subdomains[0]['subdomainId']}
    
    #  ${highest_package}=  get_highest_license_pkg
    #  ${resp}=  Account SignUp  Simi  Dany  ${None}  ${domains}  ${sub_domains}  ${ConsMobilenum}    ${highest_package[0]}
    #  Log  ${resp.json()}
    #  Should Be Equal As Strings    ${resp.status_code}    200
    #  ${resp}=  Account Activation  ${ConsMobilenum}   0
    #  Log   ${resp.json()}
    #  Should Be Equal As Strings    ${resp.status_code}    200
    #  ${resp}=  Account Set Credential  ${ConsMobilenum}  ${PASSWORD}  0
    #  Should Be Equal As Strings    ${resp.status_code}    200

     ${resp}=  Encrypted Provider Login  ${ConsMobilenum}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${ConsMobilenum}${\n}
     Set Suite Variable  ${ConsMobilenum}
     ${DAY1}=  db.get_date_by_timezone  ${tz}
     ${accId3}=  get_acc_id  ${ConsMobilenum}
      clear_Consumermsg  ${CUSERNAME29}
    clear_Providermsg  ${ConsMobilenum}
    clear_queue    ${ConsMobilenum}
    clear_service  ${ConsMobilenum}
    clear_customer   ${ConsMobilenum}
    clear_Item   ${ConsMobilenum}

    #  Set Suite Variable  ${DAY1}  ${DAY1}
    #  ${list}=  Create List  1  2  3  4  5  6  7
    #  Set Suite Variable  ${list}  ${list}
    #  ${ph1}=  Evaluate  ${ConsMobilenum}+1000000000
    #  ${ph2}=  Evaluate  ${ConsMobilenum}+2000000000
    #  ${views}=  Random Element    ${Views}
    #  ${name1}=  FakerLibrary.name
    #  ${name2}=  FakerLibrary.name
    #  ${name3}=  FakerLibrary.name
    #  ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
    #  ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
    #  ${emails1}=  Emails  ${name3}  Email  ${P_Email}183.${test_mail}  ${views}
    #  ${bs}=  FakerLibrary.bs
    #  ${city}=   get_place
    #  ${latti}=  get_latitude
    #  ${longi}=  get_longitude
    #  ${companySuffix}=  FakerLibrary.companySuffix
    #  ${postcode}=  FakerLibrary.postcode
    #  ${address}=  get_address
    #  ${parking}   Random Element   ${parkingType}
    #  ${24hours}    Random Element    ${bool}
    #  ${desc}=   FakerLibrary.sentence
    #  ${url}=   FakerLibrary.url
    #  ${sTime}=  add_timezone_time  ${tz}  0  15  
    #  Set Suite Variable   ${sTime}
    #  ${eTime}=  add_timezone_time  ${tz}  0  45  
    #  Set Suite Variable   ${eTime}
    #  ${resp}=  Update Business Profile With Schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}  ${EMPTY}
    #  Log  ${resp.json()}
    #  Should Be Equal As Strings    ${resp.status_code}    200

    #  ${fields}=   Get subDomain level Fields  ${domains}  ${sub_domains}
    #  Log  ${fields.json()}
    #  Should Be Equal As Strings    ${fields.status_code}   200

    #  ${virtual_fields}=  get_Subdomainfields  ${fields.json()}

    #  ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${sub_domains}
    #  Log  ${resp.json()}
    #  Should Be Equal As Strings  ${resp.status_code}  200

    #  ${resp}=  Get specializations Sub Domain  ${domains}  ${sub_domains}
    #  Should Be Equal As Strings    ${resp.status_code}   200

    #  ${spec}=  get_Specializations  ${resp.json()}
    #  ${resp}=  Update Specialization  ${spec}
    #  Log  ${resp.json()}
    #  Should Be Equal As Strings    ${resp.status_code}   200


    #  ${resp}=  Update Waitlist Settings  ${calc_mode[0]}   ${EMPTY}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
    #  Should Be Equal As Strings  ${resp.status_code}  200
     
    #  ${resp}=  Enable Waitlist
    #  Log   ${resp.json()}
    #  Should Be Equal As Strings  ${resp.status_code}  200


    # ${resp}=  Enable Appointment
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    
    #  sleep  1s
    #  ${resp}=  Get jaldeeIntegration Settings
    #  Log   ${resp.json()}
    #  Should Be Equal As Strings  ${resp.status_code}  200
    #  Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[0]} 

    #  ${resp}=  Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[1]}  ${boolean[0]}
    #  Log   ${resp.json()}
    #  Should Be Equal As Strings  ${resp.status_code}  200
    #  ${resp}=  Get jaldeeIntegration Settings
    #  Log   ${resp.json()}
    #  Should Be Equal As Strings  ${resp.status_code}  200
    #  Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}

     ${resp}=  View Waitlist Settings
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200


     ${id}=  get_id  ${ConsMobilenum}
     Set Suite Variable  ${id}
     ${bs}=  FakerLibrary.bs
     Set Suite Variable  ${bs}

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
    Set Suite Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}
    
    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${lid}   ${resp.json()[0]['id']}

    ${resp}=   Get License UsageInfo 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    sleep  2s
    ${resp}=  Get Departments
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}
    
    
        # ${resp}=  Encrypted Provider Login  ${PUSERNAME51}  ${PASSWORD}
        # Log  ${resp.json()}
        # Should Be Equal As Strings    ${resp.status_code}    200
        # delete_donation_service  ${PUSERNAME51}
        # clear_service   ${PUSERNAME51}
        # clear_queue      ${PUSERNAME51}
        # clear_location   ${PUSERNAME51}

        # ${pid}=  get_acc_id  ${PUSERNAME51}
        # Set Suite Variable  ${pid}
        
        ${resp}=  Get Account Settings
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        IF  ${resp.json()['onlinePayment']}==${bool[0]}   
        ${resp}=   Enable Disable Online Payment   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

        ${resp}=  Get Account Settings
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
         ${resp}=   Billable
    ${resp}=  Get Order Settings by account id
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableOrder']}==${bool[0]}   Enable Order Settings


  

    ${GST_num}  ${pan_num}=   db.Generate_gst_number   ${Container_id}
    ${resp}=  Update Tax Percentage  ${gstpercentage[3]}  ${GST_num} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Enable Tax
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${displayName3}=   FakerLibrary.name 
    Set Suite Variable  ${displayName3}
    ${shortDesc1}=  FakerLibrary.Sentence   nb_words=2  
    ${itemDesc1}=  FakerLibrary.Sentence   nb_words=3   
    ${price2}=  Random Int  min=50   max=300 
    ${price2}=  Convert To Number  ${price2}  1
    Set Suite Variable  ${price2}

    ${price1float}=  twodigitfloat  ${price2}

    ${itemName3}=   FakerLibrary.name  
    Set Suite Variable  ${itemName3}

    ${itemNameInLocal1}=  FakerLibrary.Sentence   nb_words=2  
  
    ${promoPrice2}=  Random Int  min=10   max=${price2} 
    ${promoPrice2}=  Convert To Number  ${promoPrice2}  1
    Set Suite Variable  ${promoPrice2}

    ${promoPrice1float}=  twodigitfloat  ${promoPrice2}

    ${promoPrcnt1}=   Evaluate    random.uniform(0.0,80)
    ${promotionalPrcnt1}=  twodigitfloat  ${promoPrcnt1}

    ${note1}=  FakerLibrary.Sentence   

    ${itemCode3}=   FakerLibrary.word 

    ${itemCode4}=   FakerLibrary.word 

    ${promoLabel1}=   FakerLibrary.word 

    ${resp}=  Create Order Item    ${displayName3}    ${shortDesc1}    ${itemDesc1}    ${price2}    ${bool[0]}    ${itemName3}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice2}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode3}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${item_id3}  ${resp.json()}

    ${displayName4}=   FakerLibrary.name 
    Set Suite Variable  ${displayName4}

    ${itemName4}=   FakerLibrary.name  
    Set Suite Variable  ${itemName4}

    ${resp}=  Create Order Item    ${displayName4}    ${shortDesc1}    ${itemDesc1}    ${price2}    ${bool[1]}    ${itemName4}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice2}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode4}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${item_id4}  ${resp.json()}

    ${startDate}=  db.get_date_by_timezone  ${tz}
    ${endDate}=  db.add_timezone_date  ${tz}  10        

    ${startDate1}=  db.get_date_by_timezone  ${tz}
    ${endDate1}=  db.add_timezone_date  ${tz}  15        

    ${noOfOccurance}=  Random Int  min=0   max=0

    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    Set Suite Variable   ${sTime1}
    ${eTime1}=  add_timezone_time  ${tz}  1  00   
    Set Suite Variable    ${eTime1}

    ${sTime2}=  add_timezone_time  ${tz}  1  05  
    Set Suite Variable   ${sTime2}
    ${eTime2}=  add_timezone_time  ${tz}  2  15   
    Set Suite Variable    ${eTime2}


    # ${list}=  Create List  1  2  3  4  5  6  7
  
    ${deliveryCharge}=  Random Int  min=50   max=100
    Set Suite Variable    ${deliveryCharge}
    ${deliveryCharge3}=  Convert To Number  ${deliveryCharge}  1
    Set Suite Variable    ${deliveryCharge3}

    ${Title}=  FakerLibrary.Sentence   nb_words=2 
    ${Text}=  FakerLibrary.Sentence   nb_words=4

    ${minQuantity3}=  Random Int  min=1   max=30
    Set Suite Variable   ${minQuantity3}

    ${maxQuantity3}=  Random Int  min=${minQuantity3}   max=50
    Set Suite Variable   ${maxQuantity3}


    ${catalogDesc}=   FakerLibrary.name 
    Set Suite Variable  ${catalogDesc}
    ${cancelationPolicy}=  FakerLibrary.Sentence   nb_words=5
    Set Suite Variable  ${cancelationPolicy}
    ${terminator}=  Create Dictionary  endDate=${endDate}  noOfOccurance=${noOfOccurance}
    Set Suite Variable  ${terminator}
    ${terminator1}=  Create Dictionary  endDate=${endDate1}  noOfOccurance=${noOfOccurance}
    Set Suite Variable  ${terminator1}
    ${timeSlots1}=  Create Dictionary  sTime=${sTime1}   eTime=${eTime1}
    ${timeSlots2}=  Create Dictionary  sTime=${sTime2}   eTime=${eTime2}
    ${timeSlots}=  Create List  ${timeSlots1}   ${timeSlots2}
    ${catalogSchedule}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate}   terminator=${terminator}   timeSlots=${timeSlots}
    Set Suite Variable  ${catalogSchedule}
    ${pickupSchedule}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate1}   terminator=${terminator1}   timeSlots=${timeSlots}

    ${pickUp}=  Create Dictionary  orderPickUp=${boolean[1]}   pickUpSchedule=${pickupSchedule}   pickUpOtpVerification=${boolean[1]}   pickUpScheduledAllowed=${boolean[1]}   pickUpAsapAllowed=${boolean[1]}
    Set Suite Variable  ${pickUp}
    ${homeDelivery}=  Create Dictionary  homeDelivery=${boolean[1]}   deliverySchedule=${pickupSchedule}   deliveryOtpVerification=${boolean[1]}   deliveryRadius=5   scheduledHomeDeliveryAllowed=${boolean[1]}   asapHomeDeliveryAllowed=${boolean[1]}   deliveryCharge=${deliveryCharge3}
    Set Suite Variable  ${homeDelivery}
    ${preInfo}=  Create Dictionary  preInfoEnabled=${boolean[1]}   preInfoTitle=${Title}   preInfoText=${Text}   
    Set Suite Variable  ${preInfo}
    ${postInfo}=  Create Dictionary  postInfoEnabled=${boolean[1]}   postInfoTitle=${Title}   postInfoText=${Text}   
    Set Suite Variable  ${postInfo}
    ${StatusList1}=  Create List  ${orderStatuses[0]}  ${orderStatuses[1]}   ${orderStatuses[2]}   ${orderStatuses[3]}  ${orderStatuses[9]}   ${orderStatuses[8]}    ${orderStatuses[11]}   ${orderStatuses[12]}
    Set Suite Variable  ${StatusList1} 
    # ${catalogItem1}=  Create Dictionary  itemId=${item_id1}    minQuantity=${minQuantity}   maxQuantity=${maxQuantity}  
    # ${catalogItem}=  Create List   ${catalogItem1}
    
    ${item1_Id}=  Create Dictionary  itemId=${item_id3}
    ${item2_Id}=  Create Dictionary  itemId=${item_id4}
    ${catalogItem1}=  Create Dictionary  item=${item1_Id}    minQuantity=${minQuantity3}   maxQuantity=${maxQuantity3}  
    ${catalogItem2}=  Create Dictionary  item=${item2_Id}    minQuantity=${minQuantity3}   maxQuantity=${maxQuantity3}  
    ${catalogItem}=  Create List   ${catalogItem1}  ${catalogItem2}
    Set Suite Variable  ${catalogItem}
    Set Suite Variable  ${orderType1}       ${OrderTypes[0]}
    Set Suite Variable  ${orderType2}       ${OrderTypes[1]}
    Set Suite Variable  ${catalogStatus}   ${catalogStatus[0]}
    Set Suite Variable  ${paymentType}     ${AdvancedPaymentType[0]}

    ${advanceAmount}=  Random Int  min=10   max=50
   
    ${far}=  Random Int  min=14  max=14
    Set Suite Variable  ${far}
    ${soon}=  Random Int  min=0   max=0
    Set Suite Variable  ${soon}
    Set Suite Variable  ${minNumberItem}   1

    Set Suite Variable  ${maxNumberItem}   5

    ${catalogName1}=   FakerLibrary.word 
    Set Suite Variable  ${catalogName1}

    ${catalogName2}=   FakerLibrary.name 
    Set Suite Variable  ${catalogName2}

    ${resp}=  Create Catalog For ShoppingList   ${catalogName1}  ${catalogDesc}   ${catalogSchedule}   ${orderType2}   ${paymentType}   ${StatusList1}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${CatalogId1}   ${resp.json()}

    ${resp}=  Create Catalog For ShoppingCart   ${catalogName2}  ${catalogDesc}   ${catalogSchedule}   ${orderType1}   ${paymentType}   ${StatusList1}   ${catalogItem}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${CatalogId2}   ${resp.json()}


    ${resp}=  Get Order Catalog    ${CatalogId1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  AddCustomer  ${MobilenumHi}  firstName=${f_Name}   lastName=${l_Name}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid15}   ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${MobilenumHi}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
# ${MobilenumRIA}  ${PASSWORDorder}
    ${resp}=  AddCustomer  ${MobilenumRIA}  firstName=${fname}   lastName=${lname}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid18}   ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${MobilenumRIA}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    
    ${DAY1}=  db.add_timezone_date  ${tz}  ${OtpPurpose['Authentication']}  
    Set Suite Variable  ${DAY1}
    ${DATE12}=  Convert Date  ${DAY1}  result_format=%a, %d %b %Y
    Set Suite Variable  ${DATE12}
    ${firstname}=  FakerLibrary.first_name
    Set Suite Variable  ${email}  ${f_Name}${ConsMobilenum}.${test_mail}

    ${cookie}  ${resp}=   Imageupload.spLogin  ${ConsMobilenum}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${caption}=  FakerLibrary.Sentence   nb_words=4

                                               
    ${resp}=   Upload ShoppingList By Provider for Pickup    ${cookie}   ${cid15}   ${caption}   ${cid15}    ${CatalogId1}   ${bool[1]}   ${DAY1}    ${sTime1}    ${eTime1}    ${CUSERNAME19}    ${email} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${orderid11}  ${orderid[0]}

    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity3}   max=${maxQuantity3}
    ${item_quantity1}=  Convert To Number  ${item_quantity1}  1
    Set Suite Variable  ${item_quantity1}

    ${orderNote}=  FakerLibrary.Sentence   nb_words=5
    Set Suite Variable  ${orderNote}

    ${resp}=   Create Order By Provider For Pickup    ${cookie}  ${cid15}   ${cid15}   ${CatalogId2}   ${boolean[1]}    ${sTime1}    ${eTime1}   ${DAY1}    ${CUSERNAME20}    ${email}  ${orderNote}  ${countryCodes[1]}  ${item_id3}   ${item_quantity1}  ${item_id4}   ${item_quantity1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${orderid12}  ${orderid[0]}


    ${resp}=  Consumer Login  ${MobilenumHi}  ${PASSWORD1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Order By Id  ${accId3}  ${orderid11}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${order_no11}  ${resp.json()['orderNumber']}

    ${resp}=   Get Order By Id  ${accId3}  ${orderid12}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${order_no12}  ${resp.json()['orderNumber']}

    # --------------------------------------------------------------------------

    ${resp}=  Encrypted Provider Login  ${ConsMobilenum}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cookie}   ${resp}=    Imageupload.spLogin     ${ConsMobilenum}     ${PASSWORD}
    Log     ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}     200
    ${caption1}=  Fakerlibrary.Sentence
    ${filecap_dict1}=  Create Dictionary   file=${jpgfile}   caption=${caption1}
    ${caption2}=  Fakerlibrary.Sentence
    ${filecap_dict2}=  Create Dictionary   file=${pngfile}   caption=${caption2}
    ${caption3}=  Fakerlibrary.Sentence
    ${filecap_dict3}=  Create Dictionary   file=${pdffile}   caption=${caption3}
    @{fileswithcaption}=    Create List   ${filecap_dict1}   ${filecap_dict2}  ${filecap_dict3}

    ${msg1}=  FakerLibrary.text
    ${resp}=  Order Mass Communication    ${cookie}    ${bool[1]}  ${bool[1]}  ${bool[1]}   ${bool[1]}   ${msg1}    ${fileswithcaption}   ${orderid11}  ${orderid12}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Messages
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    ${Order_Message}=  Set Variable   ${resp.json()['orderMessages']['massCommunication']['Consumer_APP']} 
    Log  ${Order_Message}

    ${Order_Msg}=  Replace String  ${Order_Message}  [type]   ${msg_type[0]}
    ${Order_Msg}=  Replace String  ${Order_Msg}  [consumer]   ${c15_UName}
    # ${Order_Msg}=  Replace String  ${Order_Msg}  [message]   ${msg1}

    sleep  2s
    ${resp}=  Get provider communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}        0
    Should Be Equal As Strings  ${resp.json()[0]['waitlistId']}         ${orderid11}
    # Should Be Equal As Strings  ${resp.json()[0]['msg']}                ${Order_Msg}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}     ${c14_Uid}
    # Should Be Equal As Strings  ${resp.json()[0]['attachements']}       []

    #  Should Contain 	${resp.json()[0]}   attachements
    # ${attachment-len}=  Get Length  ${resp.json()[0]['attachements']}
    # Should Be Equal As Strings  ${attachment-len}  3

    # Dictionary Should Contain Key  ${resp.json()[0]['attachements'][0]}   s3path
    # # Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .png
    # Dictionary Should Contain Key  ${resp.json()[0]['attachements'][0]}   thumbPath
    # # Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .png
    # # Should Be Equal As Strings  ${resp.json()[0]['attachements'][0]['caption']}     ${caption1}

    # Dictionary Should Contain Key  ${resp.json()[0]['attachements'][1]}   s3path
    # # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .pdf
    # Dictionary Should Contain Key  ${resp.json()[0]['attachements'][1]}   thumbPath
    # # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    # # Should Be Equal As Strings  ${resp.json()[0]['attachements'][1]['caption']}     ${caption2}

    # Dictionary Should Contain Key  ${resp.json()[0]['attachements'][1]}   s3path
    # # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    # Dictionary Should Contain Key  ${resp.json()[0]['attachements'][1]}   thumbPath
    # # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    # # Should Be Equal As Strings  ${resp.json()[0]['attachements'][1]['caption']}     ${caption3}

    # Should Be Equal As Strings  ${resp.json()[1]['owner']['id']}        0
    # Should Be Equal As Strings  ${resp.json()[1]['waitlistId']}         ${orderid12}
    # # Should Be Equal As Strings  ${resp.json()[1]['msg']}                ${Order_Msg}
    # Should Be Equal As Strings  ${resp.json()[1]['receiver']['id']}     ${c14_Uid}
    # # Should Be Equal As Strings  ${resp.json()[1]['attachements']}       []

    # #  Should Contain 	${resp.json()[1]}   attachements
    # # ${attachment-len}=  Get Length  ${resp.json()[1]['attachements']}
    # # Should Be Equal As Strings  ${attachment-len}  3

    # Dictionary Should Contain Key  ${resp.json()[1]['attachements'][0]}   s3path
    # # Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .png
    # Dictionary Should Contain Key  ${resp.json()[1]['attachements'][0]}   thumbPath
    # # Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .png
    # # Should Be Equal As Strings  ${resp.json()[0]['attachements'][0]['caption']}     ${caption1}

    # Dictionary Should Contain Key  ${resp.json()[1]['attachements'][1]}   s3path
    # # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .pdf
    # Dictionary Should Contain Key  ${resp.json()[1]['attachements'][1]}   thumbPath
    # # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    # # Should Be Equal As Strings  ${resp.json()[0]['attachements'][1]['caption']}     ${caption2}

    # Dictionary Should Contain Key  ${resp.json()[1]['attachements'][1]}   s3path
    # # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    # Dictionary Should Contain Key  ${resp.json()[1]['attachements'][1]}   thumbPath
    # # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    # # Should Be Equal As Strings  ${resp.json()[0]['attachements'][1]['caption']}     ${caption3}


    # ${resp}=  Consumer Login  ${MobilenumRIA}   ${PASSWORDorder}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Get Consumer Communications
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}        0
    # Should Be Equal As Strings  ${resp.json()[0]['waitlistId']}         ${orderid11}
    # # Should Be Equal As Strings  ${resp.json()[0]['msg']}                ${Order_Msg}
    # Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}     ${c15_Uid} 
    # Should Be Equal As Strings  ${resp.json()[0]['attachements']}       []
    #  Should Contain 	${resp.json()[0]}   attachements
    # ${attachment-len}=  Get Length  ${resp.json()[0]['attachements']}
    # Should Be Equal As Strings  ${attachment-len}  3

    # Dictionary Should Contain Key  ${resp.json()[0]['attachements'][0]}   s3path
    # # Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .png
    # Dictionary Should Contain Key  ${resp.json()[0]['attachements'][0]}   thumbPath
    # # Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .png
    # # Should Be Equal As Strings  ${resp.json()[0]['attachements'][0]['caption']}     ${caption1}

    # Dictionary Should Contain Key  ${resp.json()[0]['attachements'][1]}   s3path
    # # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .pdf
    # Dictionary Should Contain Key  ${resp.json()[0]['attachements'][1]}   thumbPath
    # # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    # # Should Be Equal As Strings  ${resp.json()[0]['attachements'][1]['caption']}     ${caption2}

    # Dictionary Should Contain Key  ${resp.json()[0]['attachements'][1]}   s3path
    # # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    # Dictionary Should Contain Key  ${resp.json()[0]['attachements'][1]}   thumbPath
    # # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    # # Should Be Equal As Strings  ${resp.json()[0]['attachements'][1]['caption']}     ${caption3}

    # Should Be Equal As Strings  ${resp.json()[1]['owner']['id']}        0
    # Should Be Equal As Strings  ${resp.json()[1]['waitlistId']}         ${orderid12}
    # # Should Be Equal As Strings  ${resp.json()[1]['msg']}                ${Order_Msg}
    # Should Be Equal As Strings  ${resp.json()[1]['receiver']['id']}     ${c15_Uid}
    # # Should Be Equal As Strings  ${resp.json()[1]['attachements']}       []
    # Should Contain 	${resp.json()[1]}   attachements
    # ${attachment-len}=  Get Length  ${resp.json()[1]['attachements']}
    # Should Be Equal As Strings  ${attachment-len}  3

    # Dictionary Should Contain Key  ${resp.json()[1]['attachements'][0]}   s3path
    # # Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .png
    # Dictionary Should Contain Key  ${resp.json()[1]['attachements'][0]}   thumbPath
    # # Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .png
    # # Should Be Equal As Strings  ${resp.json()[0]['attachements'][0]['caption']}     ${caption1}

    # Dictionary Should Contain Key  ${resp.json()[1]['attachements'][1]}   s3path
    # # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .pdf
    # Dictionary Should Contain Key  ${resp.json()[1]['attachements'][1]}   thumbPath
    # # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    # # Should Be Equal As Strings  ${resp.json()[0]['attachements'][1]['caption']}     ${caption2}

    # Dictionary Should Contain Key  ${resp.json()[1]['attachements'][1]}   s3path
    # # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    # Dictionary Should Contain Key  ${resp.json()[1]['attachements'][1]}   thumbPath
    # # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    # # Should Be Equal As Strings  ${resp.json()[0]['attachements'][1]['caption']}     ${caption3}


JD-TC-Payment By Consumer-1

    [Documentation]  Taking waitlist from consumer side and the consumer doing the prepayment  first then full payment

    # ${PO_Number}    Generate random string    8    123463789
    # ${PO_Number}    Convert To Integer  ${PO_Number}
    # ${PUSERPH2}=  Evaluate  ${PUSERNAME}+${PO_Number}
    # Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERPH2}${\n}
    # Set Suite Variable   ${PUSERPH2}
    # ${resp}=   Run Keywords  clear_queue  ${PUSERPH2}   AND  clear_service  ${PUSERPH2}  AND  clear_Item    ${PUSERPH2}  AND   clear_Coupon   ${PUSERPH2}   AND  clear_Discount  ${PUSERPH2}  AND  clear_appt_schedule   ${PUSERPH2}
    # ${licid}  ${licname}=  get_highest_license_pkg
    # Log  ${licid}
    # Log  ${licname}
    # Set Test Variable   ${licid}
    
    # ${domresp}=  Get BusinessDomainsConf
    # Log   ${domresp.content}
    # Should Be Equal As Strings  ${domresp.status_code}  200
    # ${dlen}=  Get Length  ${domresp.json()}
    # ${d1}=  Random Int   min=0  max=${dlen-1}
    # Set Test Variable  ${dom}  ${domresp.json()[${d1}]['domain']}
    # ${sdlen}=  Get Length  ${domresp.json()[${d1}]['subDomains']}
    # ${sdom}=  Random Int   min=0  max=${sdlen-1}
    # Set Test Variable  ${sub_dom}  ${domresp.json()[${d1}]['subDomains'][${sdom}]['subDomain']}


    # ${highest_package}=  get_highest_license_pkg
    #  ${resp}=  Account SignUp  Simi  Dany  ${None}  ${dom}  ${sub_dom}  ${ConsMobilenum}    ${highest_package[0]}
    #  Log  ${resp.json()}
    #  Should Be Equal As Strings    ${resp.status_code}    200
    #  ${resp}=  Account Activation  ${ConsMobilenum}   0
    #  Log   ${resp.json()}
    #  Should Be Equal As Strings    ${resp.status_code}    200
    #  ${resp}=  Account Set Credential  ${ConsMobilenum}  ${PASSWORD}  0
    #  Should Be Equal As Strings    ${resp.status_code}    200

     ${resp}=  Encrypted Provider Login  ${ConsMobilenum}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${ConsMobilenum}${\n}
     Set Suite Variable  ${ConsMobilenum}
     ${DAY1}=  db.get_date_by_timezone  ${tz}
     ${accId3}=  get_acc_id  ${ConsMobilenum}
     
     ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pid}  ${resp.json()['id']}
    Set Suite Variable  ${tz}  ${resp.json()['baseLocation']['bSchedule']['timespec'][0]['timezone']}

    
    ${DAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY}  
    # ${list}=  Create List  1  2  3  4  5  6  7
    # Set Suite Variable  ${list}  
    # @{Views}=  Create List  self  all  customersOnly
    # ${ph1}=  Evaluate  ${ConsMobilenum}+1000000000
    # ${ph2}=  Evaluate  ${ConsMobilenum}+2000000000
    # ${views}=  Evaluate  random.choice($Views)  random
    # ${name1}=  FakerLibrary.name
    # ${name2}=  FakerLibrary.name
    # ${name3}=  FakerLibrary.name
    # ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
    # ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
    # ${emails1}=  Emails  ${name3}  Email  ${P_Email}025.${test_mail}  ${views}
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
    # ${resp}=  Update Business Profile with Schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}   ${EMPTY}
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200

    # ${fields}=   Get subDomain level Fields  ${dom}  ${sub_dom}
    # Log  ${fields.content}
    # Should Be Equal As Strings    ${fields.status_code}   200

    # ${virtual_fields}=  get_Subdomainfields  ${fields.json()}

    # ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${sub_dom}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Get specializations Sub Domain  ${dom}  ${sub_dom}
    # Should Be Equal As Strings    ${resp.status_code}   200

    # ${spec}=  get_Specializations  ${resp.json()}
    
    # ${resp}=  Update Specialization  ${spec}
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}   200
    
    # # ------------- Get general details and settings of the provider and update all needed settings
    
    # ${resp}=  Get Business Profile
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${pid}  ${resp.json()['id']}

    # ${resp}=   Get License UsageInfo 
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    
    # ${resp}=  View Waitlist Settings
    # Log  ${resp.content}
    # Verify Response  ${resp}  onlineCheckIns=${bool[1]}

    # ${resp}=  Enable Waitlist
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp1}=   Run Keyword If  ${resp.json()['onlinePresence']}==${bool[0]}   Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[1]}  ${EMPTY}
    Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.content}
    Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}

    ${resp}=  Get Account Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['onlinePayment']}==${bool[0]}   
        ${resp}=   Enable Disable Online Payment   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END
    
    ${GST_num}  ${pan_num}=   db.Generate_gst_number   ${Container_id}
    ${resp}=  Update Tax Percentage  ${gstpercentage[3]}  ${GST_num} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${resp}=  Enable Tax
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${p1_lid}=  Create Sample Location

    ${min_pre1}=   Random Int   min=40   max=50
    ${Tot}=   Random Int   min=100   max=500
    ${min_pre1}=  Convert To Number  ${min_pre1}  1
    Set Suite Variable   ${min_pre1}
    ${pre_float1}=  twodigitfloat  ${min_pre1}
    Set Suite Variable   ${pre_float1}   
    ${Tot1}=  Convert To Number  ${Tot}  1 
    Set Suite Variable   ${Tot1}   

    ${P1SERVICE1}=    FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${resp}=  Create Service  ${P1SERVICE1}  ${desc}   ${service_duration}  ${status[0]}    ${btype}    ${bool[1]}  ${notifytype[2]}  ${min_pre1}  ${Tot1}  ${bool[1]}  ${bool[1]}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_sid1}  ${resp.json()}

    ${P1SERVICE2}=    FakerLibrary.word
    Set Suite Variable   ${P1SERVICE2}
    ${desc}=   FakerLibrary.sentence
    ${resp}=  Create Service  ${P1SERVICE2}  ${desc}   ${service_duration}  ${status[0]}    ${btype}    ${bool[1]}  ${notifytype[2]}  ${EMPTY}  ${Tot1}  ${bool[0]}  ${bool[1]}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_sid2}  ${resp.json()}


    ${queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%
    ${sTime}=  add_timezone_time  ${tz}  2  00  
    ${eTime}=  add_timezone_time  ${tz}  2  15  
    ${resp}=  Create Queue  ${queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${parallel}  ${capacity}  ${p1_lid}  ${p1_sid1}  ${p1_sid2}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_qid}  ${resp.json()}

    ${resp}=  ProviderLogout
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Consumer SignUp Notification   Ram   sam   ${MobilenumRIA}     ${countryCode}   email=${EmailRaigan}
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # ${resp}=  Consumer Activation  ${EmailRaigan}  1
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # ${resp}=  Consumer Set Credential Notification    ${EmailRaigan}   ${PASSWORDorder}   1   ${countryCode}
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # ${resp}=  Consumer Login Notification   ${MobilenumRIA}   ${PASSWORDorder}   ${countryCode}
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200

    # Append To File  ${EXECDIR}/data/TDD_Logs/consumernumbers.txt  ${MobilenumRIA}${\n}

    ${resp}=  Consumer Login  ${MobilenumRIA}  ${PASSWORDorder}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Suite Variable  ${f_Name}  ${resp.json()['firstName']}
    Set Suite Variable  ${l_Name}  ${resp.json()['lastName']}
    Set Suite Variable  ${ph_no}  ${resp.json()['primaryPhoneNumber']}

    

    # ${resp}=  Consumer Login  ${CUSERNAME15}  ${PASSWORD}
    # Log   ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${cid1}=  get_id  ${MobilenumRIA}
    Set Suite Variable   ${cid1}

    ${msg}=  FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${p1_qid}  ${DAY}  ${p1_sid1}  ${msg}  ${bool[0]}  ${self}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${cwid}  ${wid[0]} 
    
    ${tax1}=  Evaluate  ${Tot1}*${gstpercentage[3]}
    ${tax}=   Evaluate  ${tax1}/100
    ${totalamt}=  Evaluate  ${Tot1}+${tax}
    ${totalamt}=  twodigitfloat  ${totalamt}
    ${balamount}=  Evaluate  ${totalamt}-${min_pre1}
    ${balamount}=  twodigitfloat  ${balamount}  

    ${resp}=  Get consumer Waitlist By Id  ${cwid}  ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response  ${resp}  paymentStatus=${paymentStatus[0]}   waitlistStatus=${wl_status[3]}

    ${resp}=  Make payment Consumer Mock  ${pid}  ${min_pre1}  ${purpose[0]}  ${cwid}  ${p1_sid1}  ${bool[0]}   ${bool[1]}  ${cid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${mer}   ${resp.json()['merchantId']}  
    Set Suite Variable   ${payref}   ${resp.json()['paymentRefId']}

     ${resp}=  Encrypted Provider Login  ${ConsMobilenum}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Bill By UUId  ${cwid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

     ${resp}=  Consumer Login  ${MobilenumRIA}  ${PASSWORDorder}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200  

    # ${resp}=  Consumer Login  ${CUSERNAME15}  ${PASSWORD}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
   
    sleep   02s

    ${resp}=  Get Payment Details  account-eq=${pid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Numbers  ${resp.json()[0]['amount']}   ${min_pre1}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}   ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['paymentMode']}   ${payment_modes[5]}
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}   ${cwid}
    Should Be Equal As Strings  ${resp.json()[0]['paymentRefId']}   ${payref} 
    Should Be Equal As Strings  ${resp.json()[0]['paymentPurpose']}   ${purpose[0]}

    ${resp}=  Get Bill By consumer  ${cwid}  ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${cwid}  netTotal=${Tot1}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  
    ...   billPaymentStatus=${paymentStatus[1]}  totalAmountPaid=${min_pre1}    totalTaxAmount=${tax}
    Should Be Equal As Numbers  ${resp.json()['netRate']}   ${totalamt} 
    Should Be Equal As Numbers  ${resp.json()['amountDue']}   ${balamount} 

    sleep   1s
    ${resp}=  Get consumer Waitlist By Id  ${cwid}  ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  paymentStatus=${paymentStatus[1]}     waitlistStatus=${wl_status[0]}
    
    sleep  2s
    ${resp}=  Make payment Consumer Mock  ${pid}  ${balamount}  ${purpose[1]}  ${cwid}  ${p1_sid1}  ${bool[0]}   ${bool[1]}  ${cid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${ConsMobilenum}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200

    sleep   01s
    ${resp}=  Get Waitlist By Id  ${cwid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  waitlistStatus=${wl_status[0]}    paymentStatus=${paymentStatus[2]}


JD-TC-AssignTeamTo Appointment and waitlist-1

    [Documentation]  Assingn team to appointment. appmt okey
    # ${resp}=  Consumer SignUp Notification    Hisham   Muhammed   ${MobilenumHi}     ${countryCode}   email=${Emailhisham}
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # ${resp}=  Consumer Activation  ${Emailhisham}  1
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # ${resp}=  Consumer Set Credential Notification    ${Emailhisham}   ${PASSWORD1}   1   ${countryCode}
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # ${resp}=  Consumer Login Notification   ${MobilenumHi}   ${PASSWORD1}   ${countryCode}
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200

    # Append To File  ${EXECDIR}/data/TDD_Logs/consumernumbers.txt  ${MobilenumHi}${\n}

    # ${resp}=  Consumer Login  ${MobilenumHi}  ${PASSWORD1}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200  
    # Set Suite Variable  ${f_Name}  ${resp.json()['firstName']}
    # Set Suite Variable  ${l_Name}  ${resp.json()['lastName']}
    # Set Suite Variable  ${ph_no}  ${resp.json()['primaryPhoneNumber']}

    
    # ${resp}=  Consumer Logout
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
    
    # ${iscorp_subdomains}=  get_iscorp_subdomains_with_maxpartysize  1
    #  Log  ${iscorp_subdomains}
    #  Set Test Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
    #  Set Test Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
    #  Set Suite Variable  ${sub_domain_id}   ${iscorp_subdomains[0]['subdomainId']}
    # #  ${firstname_A}=  FakerLibrary.first_name
    # #  Set Suite Variable  ${firstname_A}
    # #  ${lastname_A}=  FakerLibrary.last_name
    # #  Set Suite Variable  ${lastname_A}
    # #  ${PUSERNAME_E}=  Evaluate  ${PUSERNAME}+9908813
    #  ${highest_package}=  get_highest_license_pkg
    #  ${resp}=  Account SignUp  Simi  Dany  ${None}  ${domains}  ${sub_domains}  ${ConsMobilenum}    ${highest_package[0]}
    #  Log  ${resp.json()}
    #  Should Be Equal As Strings    ${resp.status_code}    200
    #  ${resp}=  Account Activation  ${ConsMobilenum}  0
    #  Log   ${resp.json()}
    #  Should Be Equal As Strings    ${resp.status_code}    200
    #  ${resp}=  Account Set Credential  ${ConsMobilenum}  ${PASSWORD}  0
    #  Should Be Equal As Strings    ${resp.status_code}    200
    #  ${resp}=  Encrypted Provider Login  ${ConsMobilenum}  ${PASSWORD}
    #  Log  ${resp.json()}
    #  Should Be Equal As Strings    ${resp.status_code}    200
    # #  Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${ConsMobilenum}${\n}
    #  Set Suite Variable  ${ConsMobilenum}
    #  ${DAY1}=  db.get_date_by_timezone  ${tz}
    #  Set Suite Variable  ${DAY1}  ${DAY1}
    #  ${list}=  Create List  1  2  3  4  5  6  7
    #  Set Suite Variable  ${list}  ${list}
    #  ${ph1}=  Evaluate  ${ConsMobilenum}+1000000000
    #  ${ph2}=  Evaluate  ${ConsMobilenum}+2000000000
    #  ${views}=  Random Element    ${Views}
    #  ${name1}=  FakerLibrary.name
    #  ${name2}=  FakerLibrary.name
    #  ${name3}=  FakerLibrary.name
    #  ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
    #  ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
    #  ${emails1}=  Emails  ${name3}  Email  ${P_Email}183.${test_mail}  ${views}
    #  ${bs}=  FakerLibrary.bs
    #  ${city}=   get_place
    #  ${latti}=  get_latitude
    #  ${longi}=  get_longitude
    #  ${companySuffix}=  FakerLibrary.companySuffix
    #  ${postcode}=  FakerLibrary.postcode
    #  ${address}=  get_address
    #  ${parking}   Random Element   ${parkingType}
    #  ${24hours}    Random Element    ${bool}
    #  ${desc}=   FakerLibrary.sentence
    #  ${url}=   FakerLibrary.url
    #  ${sTime}=  add_timezone_time  ${tz}  0  15  
    #  Set Suite Variable   ${sTime}
    #  ${eTime}=  add_timezone_time  ${tz}  0  45  
    #  Set Suite Variable   ${eTime}
    #  ${resp}=  Update Business Profile With Schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}  ${EMPTY}
    #  Log  ${resp.json()}
    #  Should Be Equal As Strings    ${resp.status_code}    200

    #  ${fields}=   Get subDomain level Fields  ${domains}  ${sub_domains}
    #  Log  ${fields.json()}
    #  Should Be Equal As Strings    ${fields.status_code}   200

    #  ${virtual_fields}=  get_Subdomainfields  ${fields.json()}

    #  ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${sub_domains}
    #  Log  ${resp.json()}
    #  Should Be Equal As Strings  ${resp.status_code}  200

    #  ${resp}=  Get specializations Sub Domain  ${domains}  ${sub_domains}
    #  Should Be Equal As Strings    ${resp.status_code}   200

    #  ${spec}=  get_Specializations  ${resp.json()}
    #  ${resp}=  Update Specialization  ${spec}
    #  Log  ${resp.json()}
    #  Should Be Equal As Strings    ${resp.status_code}   200


    #  ${resp}=  Update Waitlist Settings  ${calc_mode[0]}   ${EMPTY}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
    #  Should Be Equal As Strings  ${resp.status_code}  200
     

    ${resp}=  Encrypted Provider Login  ${ConsMobilenum}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    # ${resp}=  Enable Waitlist
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200


    # ${resp}=  Enable Appointment
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    
     sleep  1s
     ${resp}=  Get jaldeeIntegration Settings
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
    #  Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[0]} 

    #  ${resp}=  Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[1]}  ${boolean[0]}
    #  Log   ${resp.json()}
    #  Should Be Equal As Strings  ${resp.status_code}  200
    #  ${resp}=  Get jaldeeIntegration Settings
    #  Log   ${resp.json()}
    #  Should Be Equal As Strings  ${resp.status_code}  200
    #  Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}

     ${resp}=  View Waitlist Settings
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200


     ${id}=  get_id  ${ConsMobilenum}
     Set Suite Variable  ${id}
     ${bs}=  FakerLibrary.bs
     Set Suite Variable  ${bs}

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
     Set Suite Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}
    
    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${lid}   ${resp.json()[0]['id']}

    ${resp}=   Get License UsageInfo 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    sleep  2s
    ${resp}=  Get Departments
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    # ${SERVICE1}=  FakerLibrary.word
    # ${s_id}=  Create Sample Service  ${SERVICE1}
    # Set Suite Variable   ${s_id}
      ${description}=  FakerLibrary.sentence

    ${ser_durtn}=   Random Int   min=2   max=10
    ${ser_amount}=   Random Int   min=200   max=500
    ${ser_amount}=  Convert To Number  ${ser_amount}  1
    Set Suite Variable    ${ser_amount} 
    ${min_pre}=   Random Int   min=10   max=50
    ${min_pre}=  Convert To Number  ${min_pre}  1
    Set Suite Variable    ${min_pre} 
    ${notify}    Random Element     ['True','False']
    ${notifytype}    Random Element     ['none','pushMsg','email']

    ${SERVICE5}=   FakerLibrary.name
    ${resp}=  Create Service  ${SERVICE5}  ${description}   ${ser_durtn}  ${status[0]}  ${btype}  ${notify}   ${notifytype}  ${EMPTY}  ${ser_amount}  ${bool[0]}  ${bool[0]}   department=${dep_id}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable    ${s_id}  ${resp.json()}

    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    # ${resp}=  AddCustomer  ${MobilenumHi}  firstName=${f_Name}   lastName=${l_Name}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${cid}   ${resp.json()}
    
   
    ${resp}=  GetCustomer  phoneNo-eq=${MobilenumHi} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()[0]['id']}

    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Suite Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment EncodedID   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId}=  Set Variable   ${resp.json()}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

     ${q_name}=    FakerLibrary.name
    # ${list2}=  Create List   1  2  3  4  5  6  7
    ${strt_time}=   add_timezone_time  ${tz}  1  00  
    ${end_time}=    add_timezone_time  ${tz}  2  00   
    ${parallel}=   FakerLibrary.Random Int  min=1   max=10 
    ${capacity}=   FakerLibrary.Random Int  min=1   max=10 
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}   ${parallel}   ${capacity}    ${lid}  ${s_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id}   ${resp.json()}

    # ${resp}=  AddCustomer  ${CUSERNAME1}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${cid}  ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${s_id}  ${q_id}  ${DAY1}  ${desc}  ${bool[1]}  ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}

    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  View Waitlist Settings
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200



    ${USERNAME1}=  Evaluate  ${ConsMobilenum}+144557005
    Set Suite Variable  ${USERNAME1}
    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    # ${pin}=  get_pincode
     # ${resp}=  Get LocationsByPincode     ${pin}
     FOR    ${i}    IN RANGE    3
        ${pin}=  get_pincode
        ${kwstatus}  ${resp} =  Run Keyword And Ignore Error  Get LocationsByPincode  ${pin}
        IF    '${kwstatus}' == 'FAIL'
                Continue For Loop
        ELSE IF    '${kwstatus}' == 'PASS'
                Exit For Loop
        END
     END
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 

    ${whpnum}=  Evaluate  ${ConsMobilenum}+77480
    ${tlgnum}=  Evaluate  ${ConsMobilenum}+65876

    ${resp}=  Create User  Muhammad  Hisham  ${dob}  ${Genderlist[0]}   ${emailsimi}   ${userType[0]}  ${pin}  ${countryCodes[0]}  ${MobilenumHi122}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${countryCodes[0]}  ${MobilenumHi122}  ${countryCodes[0]}  ${MobilenumHi122}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id1}  ${resp.json()}

    ${resp}=  Get User
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${USERNAME2}=  Evaluate  ${ConsMobilenum}+144556874
    Set Suite Variable  ${USERNAME2}
    clear_users  ${USERNAME2}
    ${firstname1}=  FakerLibrary.name
    ${lastname1}=  FakerLibrary.last_name
    ${dob1}=  FakerLibrary.Date
    ${pin}=  get_pincode
    
    ${resp}=  Create User  Reshma  Mohan  ${dob1}  ${Genderlist[0]}    ${usermail}    ${userType[0]}  ${pin}  ${countryCodes[0]}  ${MobilenumRIA}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id2}  ${resp.json()}
    
    ${USERNAME3}=  Evaluate  ${ConsMobilenum}+144557893
    Set Suite Variable  ${USERNAME3}
    clear_users  ${USERNAME3}
    ${firstname2}=  FakerLibrary.name
    ${lastname2}=  FakerLibrary.last_name
    ${dob2}=  FakerLibrary.Date
    ${pin}=  get_pincode
   
    ${resp}=  Create User  Sam  roy  ${dob2}  ${Genderlist[0]}  ${P_Email}${USERNAME3}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[0]}  ${USERNAME3}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id3}  ${resp.json()}

    

    ${team_name}=  FakerLibrary.name
    ${team_size}=  Random Int  min=10  max=50
    ${desc}=   FakerLibrary.sentence

    ${resp}=  Create Team For User  ${team_name}  ${team_size}  ${desc}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${t_id1}  ${resp.json()}

    ${user_ids}=  Create List  ${u_id1}  ${u_id2}

    ${resp}=   Assign Team To User  ${user_ids}  ${t_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Assign Team To Appointment  ${apptid1}  ${t_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SendProviderResetMail   ${MobilenumHi122}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${MobilenumHi122}  ${PASSWORDuser1}  2
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=  Encrypted Provider Login  ${MobilenumHi122}  ${PASSWORDuser1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointments Today  team-eq=id::${t_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['uid']}         ${apptid1}
    Should Be Equal As Strings  ${resp.json()[0]['apptStatus']}  ${apptStatus[2]}
    Should Be Equal As Strings  ${resp.json()[0]['teamId']}          ${t_id1}

    ${resp}=  Get Waitlist Today    team-eq=id::${t_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  SendProviderResetMail   ${MobilenumRIA}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${MobilenumRIA}  ${PASSWORDuser2}  2
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=  Encrypted Provider Login  ${MobilenumRIA}  ${PASSWORDuser2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointments Today   team-eq=id::${t_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    Should Be Equal As Strings  ${resp.json()[0]['uid']}         ${apptid1}
    Should Be Equal As Strings  ${resp.json()[0]['apptStatus']}  ${apptStatus[2]}
    Should Be Equal As Strings  ${resp.json()[0]['teamId']}          ${t_id1}


    ${resp}=  Get Waitlist Today    team-eq=id::${t_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}         ${wid}
    Should Be Equal As Strings  ${resp.json()[0]['waitlistStatus']}  ${wl_status[1]}
    Should Be Equal As Strings  ${resp.json()[0]['teamId']}          ${t_id1}


Appointment Cancellation-8

   [Documentation]  Send appointment communication message to Provider after cancelling appointment.
    # Comment its okey sms varified
    
    # ${resp}=  Consumer SignUp Notification    Hisham   Muhammed   ${MobilenumHi}     ${countryCode}   email=${Emailhisham}
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # ${resp}=  Consumer Activation  ${Emailhisham}  1
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # ${resp}=  Consumer Set Credential Notification    ${Emailhisham}   ${PASSWORD1}   1   ${countryCode}
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # ${resp}=  Consumer Login Notification   ${MobilenumHi}   ${PASSWORD1}   ${countryCode}
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200

    # Append To File  ${EXECDIR}/data/TDD_Logs/consumernumbers.txt  ${MobilenumHi}${\n}

    # ${resp}=  Consumer Login  ${MobilenumHi}  ${PASSWORD1}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200  
    # Set Suite Variable  ${f_Name}  ${resp.json()['firstName']}
    # Set Suite Variable  ${l_Name}  ${resp.json()['lastName']}
    # Set Suite Variable  ${ph_no}  ${resp.json()['primaryPhoneNumber']}

    
    # ${resp}=  Consumer Logout
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200

    # ${domresp}=  Get BusinessDomainsConf
    # Log  ${domresp.json()}
    # Should Be Equal As Strings  ${domresp.status_code}  200
    # ${len}=  Get Length  ${domresp.json()}
    # ${domain_list}=  Create List
    # ${subdomain_list}=  Create List
    # FOR  ${domindex}  IN RANGE  ${len}
    #     Set Test Variable  ${d}  ${domresp.json()[${domindex}]['domain']}    
    #     Append To List  ${domain_list}    ${d} 
    #     Set Test Variable  ${sd}  ${domresp.json()[${domindex}]['subDomains'][0]['subDomain']}
    #     Append To List  ${subdomain_list}    ${sd} 
    # END
    # Log  ${domain_list}
    # Log  ${subdomain_list}
    # Set Suite Variable  ${domain_list}
    # Set Suite Variable  ${subdomain_list}
    # Set Test Variable  ${d1}  ${domain_list[0]}
    # Set Test Variable  ${sd1}  ${subdomain_list[0]}

    # ${highest_package}=  get_highest_license_pkg
    
    # ${resp}=  Account SignUp   simi  Dany  ${None}  ${d1}  ${sd1}  ${ConsMobilenum}    ${highest_package[0]}
    # Log  ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # ${resp}=  Account Activation  ${ConsMobilenum}  0
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # ${resp}=  Account Set Credential  ${ConsMobilenum}  ${NEW_PASSWORD12}  0
    # Should Be Equal As Strings    ${resp.status_code}    200
    # ${resp}=  Encrypted Provider Login  ${ConsMobilenum}  ${NEW_PASSWORD12}
    # Log  ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${ConsMobilenum}${\n}
    # Set Suite Variable  ${ConsMobilenum}
    # ${pid}=  get_acc_id  ${ConsMobilenum}
    # ${id}=  get_id  ${ConsMobilenum}
    # Set Suite Variable  ${id}
    ${resp}=  Encrypted Provider Login  ${ConsMobilenum}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp}=   Enable Appointment 
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    clear_service   ${ConsMobilenum}
    clear_location  ${ConsMobilenum}
    clear_customer   ${ConsMobilenum}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

   
    # ${resp}=   Get jaldeeIntegration Settings
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # ${resp1}=   Run Keyword If  ${resp.json()['walkinConsumerBecomesJdCons']}==${bool[0]}   Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${EMPTY}
    # Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.json()}
    # Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200
   
    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]} 

    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${pid}  ${resp.json()['id']} 


    
    # ${DAY1}=  db.get_date_by_timezone  ${tz}
    # ${list}=  Create List  1  2  3  4  5  6  7
    # ${ph1}=  Evaluate  ${ConsMobilenum}+15566122
    # ${ph2}=  Evaluate  ${ConsMobilenum}+25566122
    # ${views}=  Random Element    ${Views}
    # ${name1}=  FakerLibrary.name
    # ${name2}=  FakerLibrary.name
    # ${name3}=  FakerLibrary.name
    # ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
    # ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
    # ${emails1}=  Emails  ${name3}  Email  ${EmailProConsreshma}  ${views}
    # ${bs}=  FakerLibrary.bs
    # ${city}=   get_place
    # ${latti}=  get_latitude
    # ${longi}=  get_longitude
    # ${companySuffix}=  FakerLibrary.companySuffix
    # ${postcode}=  FakerLibrary.postcode
    # ${address}=  get_address
    # ${parking}   Random Element   ${parkingType}
    # ${24hours}    Random Element    ${bool}
    # ${desc}=   FakerLibrary.sentence
    # ${url}=   FakerLibrary.url
    # ${sTime}=  add_timezone_time  ${tz}  0  15  
    # ${eTime}=  add_timezone_time  ${tz}  0  45  
    # ${resp}=  Update Business Profile with Schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}   ${address}   ${ph_nos1}   ${ph_nos2}   ${emails1}   ${EMPTY}
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=  Get Business Profile
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}  

    ${lid}=  Create Sample Location  
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}

    clear_appt_schedule   ${ConsMobilenum}
    
    # ${DAY1}=  db.get_date_by_timezone  ${tz}
    # ${DAY2}=  db.add_timezone_date  ${tz}  10        
    # ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    # ${delta}=  FakerLibrary.Random Int  min=10  max=60
    # ${eTime1}=  add_two   ${sTime1}  ${delta}
    # ${SERVICE1}=   FakerLibrary.name

    # ${min_pre1}=   Random Int   min=40   max=50
    # ${Tot}=   Random Int   min=100   max=500
    # ${min_pre1}=  Convert To Number  ${min_pre1}  1
    # Set Suite Variable   ${min_pre1}
    # ${pre_float1}=  twodigitfloat  ${min_pre1}
    # Set Suite Variable   ${pre_float1}   
    # ${Tot1}=  Convert To Number  ${Tot}  1 
    # Set Suite Variable   ${Tot1}   

    # ${P1SERVICE1}=    FakerLibrary.word
    # ${desc}=   FakerLibrary.sentence
    # ${resp}=  Create Service  ${P1SERVICE1}  ${desc}   ${service_duration}  ${status[0]}    ${btype}    ${bool[1]}  ${notifytype[2]}  ${min_pre1}  ${Tot1}  ${bool[1]}  ${bool[1]}
    # Log   ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${p1_sid1}  ${resp.json()}

      ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    # ${SERVICE1}=  FakerLibrary.word
    # ${s_id}=  Create Sample Service  ${SERVICE1}
    # Set Suite Variable   ${s_id}
      ${description}=  FakerLibrary.sentence

    ${ser_durtn}=   Random Int   min=2   max=10
    ${ser_amount}=   Random Int   min=200   max=500
    ${ser_amount}=  Convert To Number  ${ser_amount}  1
    Set Suite Variable    ${ser_amount} 
    ${min_pre}=   Random Int   min=10   max=50
    ${min_pre}=  Convert To Number  ${min_pre}  1
    Set Suite Variable    ${min_pre} 
    ${notify}    Random Element     ['True','False']
    ${notifytype}    Random Element     ['none','pushMsg','email']

    ${SERVICE1}=   FakerLibrary.name
    ${resp}=  Create Service  ${SERVICE1}  ${description}   ${ser_durtn}  ${status[0]}  ${btype}  ${notify}   ${notifytype}  ${EMPTY}  ${ser_amount}  ${bool[0]}  ${bool[0]}   department=${dep_id}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable    ${s_id}  ${resp.json()}


    # ${s_id}=  Create Sample Service  ${SERVICE1}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
    Set Test Variable   ${slot2}   ${resp.json()['availableSlots'][1]['time']}


    ${resp}=  AddCustomer  ${MobilenumHi}  firstName=${f_Name}   lastName=${l_Name}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()}
    
    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}  

    ${lid}=  Create Sample Location  
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}

    clear_appt_schedule   ${ConsMobilenum}
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${SERVICE1}=   FakerLibrary.name
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
    Set Test Variable   ${slot2}   ${resp.json()['availableSlots'][1]['time']}


   
    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${apptTime}=  db.get_tz_time_secs  ${tz} 
    ${apptTakenTime}=  db.remove_secs   ${apptTime}
    ${UpdatedTime}=  db.get_date_time_by_timezone  ${tz}
    ${statusUpdatedTime}=   db.remove_date_time_secs   ${UpdatedTime}

    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment EncodedID   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId}=  Set Variable   ${resp.json()}

    
   
    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uid']}   ${apptid1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[2]}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}   ${fname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['appmtDate']}   ${DAY1}
    Should Be Equal As Strings  ${resp.json()['appmtTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

    ${reason}=  Random Element  ${cancelReason}
    ${msg}=   FakerLibrary.word
    ${resp}=    Provider Cancel Appointment  ${apptid1}  ${reason}  ${msg}  ${DAY1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    sleep   2s
    ${resp}=  Get Appointment Status   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()[1]['appointmentStatus']}   ${apptStatus[4]}
    Should Contain  "${resp.json()}"  ${apptStatus[4]}

    ${cookie}  ${resp}=  Imageupload.conLogin  ${MobilenumHi}   ${PASSWORD1}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${caption1}=  Fakerlibrary.sentence
    ${filecap_dict1}=  Create Dictionary   file=${jpgfile}   caption=${caption1}
    @{fileswithcaption}=  Create List   ${filecap_dict1}
    
   
    ${resp}=  Imageupload.CAppmntcomm   ${cookie}   ${apptid1}  ${pid}  ${msg}  ${messageType[0]}  ${caption1}  ${EMPTY}  ${jpgfile}  
    Log  ${resp}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${MobilenumHi}  ${PASSWORD1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Consumer Communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[1]['waitlistId']}         ${apptid1}
    # Should Be Equal As Strings  ${resp.json()[1]['msg']}                ${msg}
    # Should Be Equal As Strings  ${resp.json()[1]['receiver']['id']}     ${id}
    Should Be Equal As Strings  ${resp.json()[1]['accountId']}          ${pid}    
