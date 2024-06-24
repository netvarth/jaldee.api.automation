*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Run Keywords  Delete All Sessions
Force Tags        ENQUIRY
Library           Collections
Library           FakerLibrary
Library           random
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
# Variables         /ebs/TDD/varfiles/consumerlist.py


*** Variables ***

@{emptylist}
${count}  ${50}



*** Test Cases ***   
TC-1
    [Documentation]   Checking if condition

    ${resp}=  Encrypted Provider Login  ${PUSERNAME180}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${s_id}=  Set Variable  ${NONE}
    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # IF   '${resp.content}' != '${emptylist}'
    IF   "$resp.content" != "${emptylist}"
        
        ${service_len}=  Get Length   ${resp.json()}
        FOR   ${i}  IN RANGE   ${service_len}
            IF  '${resp.json()[${i}]['status']}' == '${status[0]}'
                Set Test Variable   ${s_id}   ${resp.json()[${i}]['id']}

                IF  '${resp.json()[${i}]['isPrePayment']}' == '${bool[1]}'
                    ${maxbookings}=   Random Int   min=5   max=10
                    ${resp}=  Update Service  ${s_id}  ${resp.json()[${i}]['name']}  ${EMPTY}  ${resp.json()[${i}]['serviceDuration']}  ${resp.json()[${i}]['status']}  ${btype}  ${resp.json()[${i}]['notification']}  ${resp.json()[${i}]['notificationType']}  ${resp.json()[${i}]['minPrePaymentAmount']}  ${resp.json()[${i}]['totalAmount']}  ${resp.json()[${i}]['isPrePayment']}  ${resp.json()[${i}]['taxable']}  maxBookingsAllowed=${count}
                    Log  ${resp.content}
                    Should Be Equal As Strings  ${resp.status_code}  200
                ELSE

                    ${maxbookings}=   Random Int   min=5   max=10
                    ${resp}=  Update Service  ${s_id}  ${resp.json()[${i}]['name']}  ${EMPTY}  ${resp.json()[${i}]['serviceDuration']}  ${resp.json()[${i}]['status']}  ${btype}  ${resp.json()[${i}]['notification']}  ${resp.json()[${i}]['notificationType']}  ${EMPTY}  ${resp.json()[${i}]['totalAmount']}  ${resp.json()[${i}]['isPrePayment']}  ${resp.json()[${i}]['taxable']}  maxBookingsAllowed=${count}
                    Log  ${resp.content}
                    Should Be Equal As Strings  ${resp.status_code}  200

                END
                BREAK

            END
        END

        ${srv_val}=    Get Variable Value    ${s_id}
        IF  '${srv_val}'=='${None}'
            ${SERVICE1}=    FakerLibrary.job
            ${maxbookings}=   Random Int   min=5   max=10
            ${s_id}=  Create Sample Service  ${SERVICE1}  maxBookingsAllowed=${count}
        END
    ELSE

        ${SERVICE1}=    FakerLibrary.job
        ${maxbookings}=   Random Int   min=5   max=10
        ${s_id}=  Create Sample Service  ${SERVICE1}  maxBookingsAllowed=${count}

    END

*** Comments ***
    [Documentation]   Create Location with timezone=Asia/Dubai
    Comment  Provider in Middle East (UAE)
    ${PO_Number}=  FakerLibrary.Numerify  %#####
    ${MEProvider}=  Evaluate  ${PUSERNAME}+${PO_Number}

    ${licpkgid}  ${licpkgname}=  get_highest_license_pkg

    ${resp}=  Get BusinessDomainsConf
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${dom_len}=  Get Length  ${resp.json()}
    ${dom}=  random.randint  ${0}  ${dom_len-1}
    ${sdom_len}=  Get Length  ${resp.json()[${dom}]['subDomains']}
    Set Test Variable  ${domain}  ${resp.json()[${dom}]['domain']}
    Log   ${domain}
    
    FOR  ${subindex}  IN RANGE  ${sdom_len}
        ${sdom}=  random.randint  ${0}  ${sdom_len-1}
        Set Test Variable  ${subdomain}  ${resp.json()[${dom}]['subDomains'][${subindex}]['subDomain']}
        ${is_corp}=  check_is_corp  ${subdomain}
        Exit For Loop If  '${is_corp}' == 'False'
    END
    Log   ${subdomain}

    ${fname}=  FakerLibrary.name
    ${lname}=  FakerLibrary.lastname
    ${resp}=  Account SignUp  ${fname}  ${lname}  ${None}  ${domain}  ${subdomain}  ${MEProvider}  ${licpkgid}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Account Activation  ${MEProvider}  0
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Account Set Credential  ${MEProvider}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${MEProvider}
    Should Be Equal As Strings    ${resp.status_code}    200

    sleep  01s
    ${resp}=  Encrypted Provider Login  ${MEProvider}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${pid1}  ${decrypted_data['id']}

    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${list}=  Create List  1  2  3  4  5  6  7
    # ${ph1}=  Evaluate  ${MEProvider}+15566122
    # ${ph2}=  Evaluate  ${MEProvider}+25566122
    # ${views}=  Random Element    ${Views}
    # ${name1}=  FakerLibrary.name
    # ${name2}=  FakerLibrary.name
    # ${name3}=  FakerLibrary.name
    # ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
    # ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
    # ${emails1}=  Emails  ${name3}  Email  ${P_Email}${MEProvider}.${test_mail}  ${views}
    # ${bs}=  FakerLibrary.bs
    # ${companySuffix}=  FakerLibrary.companySuffix
    # ${address} =  FakerLibrary.address
    # ${postcode}=  FakerLibrary.postcode
    # # ${latti}  ${longi}  ${city}  ${country_abbr}  ${AE_tz}=  FakerLibrary.Local Latlng  country_code=AE  coords_only=False
    # ${latti}  ${longi}  ${city}  ${country_abbr}  ${AE_tz}=  FakerLibrary.Local Latlng
    # ${AE_tz}=  Set Variable  Asia/Dubai  
    # ${DAY}=  db.get_date_by_timezone  ${AE_tz}
    # ${parking}   Random Element   ${parkingType}
    # ${24hours}    Random Element    ${bool}
    # ${desc}=   FakerLibrary.sentence
    # ${url}=   FakerLibrary.url
    # ${sTime}=  db.get_time_by_timezone  ${AE_tz}  
    # ${eTime}=  db.add_timezone_time  ${AE_tz}  0  30  
    # ${resp}=  Update Business Profile with Schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}   ${EMPTY}  timezone=${AE_tz}
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200

    ${list}=  Create List  1  2  3  4  5  6  7
    ${latti}  ${longi}  ${city}  ${country_abbr}  ${AE_tz}=  FakerLibrary.Local Latlng
    ${AE_tz}=  Set Variable  Asia/Dubai
    ${latti}=  Set Variable  25.243183780208067
    ${longi}=  Set Variable  55.480148092471524
    # ${AE_tz}=  FakerLibrary.Timezone
    ${address1} =  FakerLibrary.address
    ${postcode1}=  FakerLibrary.postcode
    ${DAY1}=  db.get_date_by_timezone  ${AE_tz}
    ${DAY2}=  db.add_timezone_date  ${AE_tz}  10     
    ${sTime1}=  add_timezone_time  ${AE_tz}  0  30  
    ${eTime1}=  add_timezone_time  ${AE_tz}  1  00  
    ${parking}    Random Element     ${parkingType} 
    ${24hours}    Random Element    ['True','False']
    ${url}=   FakerLibrary.url
    ${resp}=  Create Location  ${city}  ${longi}  ${latti}  ${url}  ${postcode1}  ${address1}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  timezone=${AE_tz}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${p2_l1}  ${resp.json()}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable   ${p2_l1}   ${resp.json()[0]['id']}

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

*** Comments ***

    ${fields}=   Get subDomain level Fields  ${domain}  ${subdomain}
    Log  ${fields.content}
    Should Be Equal As Strings    ${fields.status_code}   200

    ${virtual_fields}=  get_Subdomainfields  ${fields.json()}

    ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${subdomain}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get specializations Sub Domain  ${domain}  ${subdomain}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${spec}=  get_Specializations  ${resp.json()}
    ${resp}=  Update Specialization  ${spec}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    Set Test Variable  ${email_id}  ${P_Email}${MEProvider}.${test_mail}

    ${resp}=  Update Email   ${pid1}   ${fname}  ${lname}   ${email_id}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Enable Appointment
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep   01s
    
    ${resp}=  Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[0]}  ${boolean[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          

    ${resp}=  Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${p2_l1}   ${resp.json()[0]['id']}

    ${SERVICE1}=   FakerLibrary.job
    ${p2_s1}=  Create Sample Service  ${SERVICE1}

    ${DAY3}=  db.get_date_by_timezone  ${AE_tz}
    ${DAY4}=  db.add_timezone_date  ${AE_tz}  10  
    ${sTime2}=  add_timezone_time  ${AE_tz}  1  00  
    ${eTime2}=  add_timezone_time  ${AE_tz}  1  30  
    ${schedule_name}=  FakerLibrary.administrative unit
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    # ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=5
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY3}  ${DAY4}  ${EMPTY}  ${sTime2}  ${eTime2}  ${parallel}  ${parallel}  ${p2_l1}  ${duration}  ${bool1}  ${p2_s1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${p2_sch1}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${p2_sch1}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${p2_sch1}   name=${schedule_name}  apptState=${Qstate[0]}
    
    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

