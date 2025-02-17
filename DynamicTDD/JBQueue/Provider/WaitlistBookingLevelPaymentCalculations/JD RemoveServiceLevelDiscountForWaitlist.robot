*** Settings ***
Suite Teardown    Delete All Sessions 
Test Teardown     Delete All Sessions
Force Tags        Waitlist
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 
# Variables         /ebs/TDD/varfiles/consumermail.py
Variables         /ebs/TDD/varfiles/hl_providers.py

*** Keywords ***

Get Billable Subdomain
    [Arguments]   ${domain}  ${jsondata}  ${posval}  
    ${length}=  Get Length  ${jsondata.json()[${posval}]['subDomains']}
    FOR  ${pos}  IN RANGE  ${length}
            Set Suite Variable  ${subdomain}  ${jsondata.json()[${posval}]['subDomains'][${pos}]['subDomain']}
            ${resp}=   Get Sub Domain Settings    ${domain}    ${subdomain}
            Should Be Equal As Strings    ${resp.status_code}    200
            Exit For Loop IF  '${resp.json()['serviceBillable']}' == '${bool[1]}'
    END
    RETURN  ${subdomain}  ${resp.json()['serviceBillable']}



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

*** Variables ***

@{service_names}
${waitlistedby}           PROVIDER
${SERVICE1}               SERVICE1001
${SERVICE2}               SERVICE2002
${SERVICE3}               SERVICE3003
${SERVICE4}               SERVICE4004
${SERVICE5}               SERVICE3005
${SERVICE6}               SERVICE4006
${sample}                     4452135820
${self}                   0

*** Test Cases ***

JD-TC-RemoveServiceLevelDiscountforwaitlist-1
      [Documentation]   Apply Service Level Discount then remove that Discount.

    # ${PUSERPH0}=  Evaluate  ${PUSERNAME}+3378839
    # Set Suite Variable   ${PUSERPH0}
    
    # ${licid}  ${licname}=  get_highest_license_pkg
    # Log  ${licid}
    # Log  ${licname}
    # ${domresp}=  Get BusinessDomainsConf
    # Log   ${domresp.json()}
    # Should Be Equal As Strings  ${domresp.status_code}  200
    # ${dlen}=  Get Length  ${domresp.json()}
    # FOR  ${pos}  IN RANGE  ${dlen}  
    #     Set Suite Variable  ${d1}  ${domresp.json()[${pos}]['domain']}
    #     ${sd1}  ${check}=  Get Billable Subdomain  ${d1}  ${domresp}  ${pos}  
    #     Set Suite Variable   ${sd1}
    #     Exit For Loop IF     '${check}' == '${bool[1]}'
    # END
    # Log  ${d1}
    # Log  ${sd1}

    # ${firstname}=  FakerLibrary.first_name
    # ${lastname}=  FakerLibrary.last_name
    # ${address}=  FakerLibrary.address
    # ${dob}=  FakerLibrary.Date
    # ${gender}=    Random Element    ${Genderlist}
    # ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${d1}  ${sd1}  ${PUSERPH0}  ${licid}
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    202

    # ${resp}=  Account Activation  ${PUSERPH0}  0
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # # Should Be Equal As Strings  "${resp.json()}"    "true"
    # Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERPH0}${\n}

    # ${resp}=  Account Set Credential  ${PUSERPH0}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${PUSERPH0}
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    # Log  ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}   200

    #    ${pid0}=  get_acc_id  ${PUSERPH0}
    # Set Suite Variable  ${pid0}

    ${firstname}  ${lastname}  ${PUSERPH0}  ${login_id}=  Provider Signup  
    Set Suite Variable    ${PUSERPH0}

  
    # ${list}=  Create List  1  2  3  4  5  6  7
    # ${ph1}=  Evaluate  ${PUSERPH0}+15566122
    # ${ph2}=  Evaluate  ${PUSERPH0}+25566122
    # ${views}=  Random Element    ${Views}
    # ${name1}=  FakerLibrary.name
    # ${name2}=  FakerLibrary.name
    # ${name3}=  FakerLibrary.name
    # ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
    # ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
    # ${emails1}=  Emails  ${name3}  Email  ${P_Email}183.${test_mail}  ${views}
    # ${bs}=  FakerLibrary.bs
    # ${companySuffix}=  FakerLibrary.companySuffix
    # # ${city}=   FakerLibrary.state
    # # ${latti}=  get_latitude
    # # ${longi}=  get_longitude
    # # ${postcode}=  FakerLibrary.postcode
    # # ${address}=  get_address
    # ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    # ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    # Set Suite Variable  ${tz}
    # ${parking}   Random Element   ${parkingType}
    # ${24hours}    Random Element    ${bool}
    # ${desc}=   FakerLibrary.sentence
    # ${url}=   FakerLibrary.url
    # ${DAY1}=  db.get_date_by_timezone  ${tz}
    # ${sTime}=  add_timezone_time  ${tz}  0  15  
    # ${eTime}=  add_timezone_time  ${tz}  0  45  
    # ${resp}=  Update Business Profile with Schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}   ${EMPTY}
    # Log  ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=  Get Business Profile
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}
    # Set Suite Variable  ${account_id1}  ${resp.json()['id']}

      
        # ${fields}=   Get subDomain level Fields  ${d1}  ${sd1}
        # Log  ${fields.json()}
        # Should Be Equal As Strings    ${fields.status_code}   200
        # ${virtual_fields}=  get_Subdomainfields  ${fields.json()}
        # ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${sd1}
        # Log  ${resp.json()}
        # Should Be Equal As Strings  ${resp.status_code}  200
        # ${resp}=  Get specializations Sub Domain  ${d1}  ${sd1}
        # Log  ${resp.json()}
        # Should Be Equal As Strings    ${resp.status_code}   200
        # ${spec}=  get_Specializations  ${resp.json()}
        # ${resp}=  Update Specialization  ${spec}
        # Log  ${resp.json()}
        # Should Be Equal As Strings    ${resp.status_code}   200


     
    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=  Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[1]}  ${boolean[0]}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     
    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
    # Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}

    ${resp}=  Get Bill Settings 
    Log   ${resp.json}
    IF  ${resp.status_code}!=200
        Log   Status code is not 200: ${resp.status_code}
        ${resp}=  Enable Disable bill  ${bool[1]}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
    ELSE IF  ${resp.json()['enablepos']}==${bool[0]}
        ${resp}=  Enable Disable bill  ${bool[1]}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    ${resp}=  Get Bill Settings 
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['enablepos']}    ${bool[1]}

    ${resp}=  Get Waitlist Settings
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enabledWaitlist']}==${bool[0]}   
        ${resp}=   Enable Waitlist
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    ${resp}=  Get Waitlist Settings
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enabledWaitlist']}   ${bool[1]}

    ${resp}=  Get Waitlist Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${resp}=  Update Waitlist Settings  ${calc_mode[0]}  ${EMPTY}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
    Log    ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get jp finance settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    IF  ${resp.json()['enableJaldeeFinance']}==${bool[0]}
        ${resp1}=    Enable Disable Jaldee Finance   ${toggle[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=  Get jp finance settings    
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableJaldeeFinance']}  ${bool[1]}

    # ${resp}=    Get Bill Settings
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=    Enable Disable bill    ${boolean[1]}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

      ${resp}=  AddCustomer  ${CUSERNAME1}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${cid}  ${resp.json()}

      ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME1}
      Log   ${resp.json()}
      Should Be Equal As Strings      ${resp.status_code}  200
     
      ${resp}=  Create Sample Location  
      Set Suite Variable    ${loc_id1}    ${resp}  

      ${resp}=   Get Location ById  ${loc_id1}
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${tz}  ${resp.json()['timezone']}

      ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
      Set Suite Variable  ${CUR_DAY}
  
      ${resp}=   Create Sample Service  ${SERVICE1}
      Set Suite Variable    ${ser_id1}    ${resp}  
      ${resp}=   Create Sample Service  ${SERVICE2}
      Set Suite Variable    ${ser_id2}    ${resp}  
      ${resp}=   Create Sample Service  ${SERVICE3}
      Set Suite Variable    ${ser_id3}    ${resp}  
      ${q_name}=    FakerLibrary.name
      Set Suite Variable    ${q_name}
      ${list}=  Create List   1  2  3  4  5  6  7
      Set Suite Variable    ${list}
      ${strt_time}=   db.add_timezone_time     ${tz}  1  00
      Set Suite Variable    ${strt_time}
      ${end_time}=    db.add_timezone_time     ${tz}  3  00 
      Set Suite Variable    ${end_time}   
      ${parallel}=   Random Int  min=1   max=1
      Set Suite Variable   ${parallel}
      ${capacity}=  Random Int   min=10   max=20
      Set Suite Variable   ${capacity}
      ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${loc_id1}  ${ser_id1}  ${ser_id2}  ${ser_id3}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${que_id1}   ${resp.json()}
      ${desc}=   FakerLibrary.word
      Set Suite Variable  ${desc}
      ${resp}=  Add To Waitlist  ${cid}  ${ser_id1}  ${que_id1}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid} 
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Suite Variable  ${wid}  ${wid[0]}
      ${resp}=  Get Waitlist By Id  ${wid} 
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[1]}  partySize=1  appxWaitingTime=0  waitlistedBy=${waitlistedby}   personsAhead=0
      Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
      Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${ser_id1}
      Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid}
      Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid}
      Should Be Equal As Strings  ${resp.json()['paymentStatus']}         ${paymentStatus[0]}
      Set Test Variable   ${fullAmount}  ${resp.json()['fullAmt']}         
    ${discount1}=     FakerLibrary.word
    ${desc}=   FakerLibrary.word
    ${discountprice1}=     Random Int   min=50   max=100
    ${discountprice}=  Convert To Number  ${discountprice1}  1
    Set Suite Variable   ${discountprice}
    ${resp}=   Create Discount  ${discount1}   ${desc}    ${discountprice}   ${calctype[1]}  ${disctype[0]}
    Log  ${resp.json()}
    Set Suite Variable   ${discountId}   ${resp.json()}   
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Discounts 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${discAmt}=    Evaluate  ${fullAmount}-${discountprice}

    ${resp}=   Apply Service Level Discount for waitlist    ${wid}    ${discountId}   ${discountprice}    ${discount1}    ${discount1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['netRate']}                  ${discAmt}
    Should Be Equal As Strings  ${resp.json()['billPaymentStatus']}         ${paymentStatus[0]}

    ${resp}=   Remove Service Level Discount for waitlist    ${wid}    ${discountId}   ${discountprice}    ${discount1}    ${discount1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['netRate']}                  ${fullAmount}
    Should Be Equal As Strings  ${resp.json()['billPaymentStatus']}         ${paymentStatus[0]}


JD-TC-RemoveServiceLevelDiscountforwaitlist-2
    [Documentation]   Apply service level discount for future waitlist.(online) and then remove that discount


    # ${resp}=  Consumer Login  ${CUSERNAME13}  ${PASSWORD}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200   

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}
    Set Suite Variable  ${account_id}  ${resp.json()['id']}

    #............provider consumer creation..........

    ${PH_Number}=  FakerLibrary.Numerify  %#####
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Suite Variable  ${PCPHONENO2}  555${PH_Number}

    ${fname2}=  generate_firstname
    Set Suite Variable  ${fname2}
    ${lastname2}=  FakerLibrary.last_name
  
    ${resp}=  AddCustomer  ${PCPHONENO2}    firstName=${fname2}   lastName=${lastname2}  countryCode=${countryCodes[1]} 
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  GetCustomer  phoneNo-eq=${PCPHONENO2}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()[0]['id']}

    ${resp}=    Send Otp For Login    ${PCPHONENO2}    ${account_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login    ${PCPHONENO2}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token2}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer Login with token   ${PCPHONENO2}    ${account_id}  ${token2} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable    ${cid1}    ${resp.json()['providerConsumer']}   

    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${Start_DAY}=  db.add_timezone_date  ${tz}  1 
    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${cid1}  ${account_id}  ${que_id1}  ${Start_DAY}  ${ser_id2}  ${cnote}  ${bool[0]}  ${self}   location=${loc_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid2}  ${wid[0]}
    ${resp}=  Get consumer Waitlist By Id   ${wid2}  ${account_id}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${fullAmount}  ${resp.json()['fullAmt']}   

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME13}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    # Set Test Variable  ${cid2}  ${resp.json()[0]['id']}

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${discount1}=     FakerLibrary.word
    ${discAmt}=    Evaluate  ${fullAmount}-${discountprice}

    ${resp}=   Apply Service Level Discount for waitlist    ${wid2}    ${discountId}   ${discountprice}    ${discount1}    ${discount1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['netRate']}                  ${discAmt}
    # Should Be Equal As Strings  ${resp.json()['billPaymentStatus']}         ${paymentStatus[0]}

    ${resp}=   Remove Service Level Discount for waitlist    ${wid2}    ${discountId}   ${discountprice}    ${discount1}    ${discount1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['netRate']}                  ${fullAmount}
    Should Be Equal As Strings  ${resp.json()['billPaymentStatus']}         ${paymentStatus[0]}

JD-TC-RemoveServiceLevelDiscountforwaitlist-3

    [Documentation]   Apply service level discount,where discount price is empty and remove that discount.

    ${resp}=  Encrypted Provider Login    ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${discount2}=     FakerLibrary.word
    Set Suite Variable   ${discount2}

    ${desc}=   FakerLibrary.word
    ${discountprice1}=     Random Int   min=50   max=100
    ${discountprice}=  Convert To Number  ${discountprice1}  1
    Set Test Variable   ${discountprice}
    ${resp}=   Create Discount  ${discount2}   ${desc}    ${discountprice}   ${calctype[1]}  ${disctype[0]}
    Log  ${resp.json()}
    Set Suite Variable   ${discountId2}   ${resp.json()}   
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Discounts 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

      ${resp}=  Get Waitlist By Id  ${wid} 
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${fullAmount}  ${resp.json()['fullAmt']}   

    ${discAmt}=    Evaluate  ${fullAmount}-${discountprice}

    ${resp}=   Apply Service Level Discount for waitlist    ${wid}    ${discountId2}   ${EMPTY}    ${discount2}    ${discount2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['netRate']}                  ${discAmt}
    # Should Be Equal As Strings  ${resp.json()['billPaymentStatus']}         ${paymentStatus[0]}

    ${resp}=   Remove Service Level Discount for waitlist    ${wid}    ${discountId2}   ${discountprice}    ${discount2}    ${discount2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['netRate']}                  ${fullAmount}
    Should Be Equal As Strings  ${resp.json()['billPaymentStatus']}         ${paymentStatus[0]}

JD-TC-RemoveServiceLevelDiscountforwaitlist-4

    [Documentation]   remove service level discount,where both note is empty.

    ${resp}=  Encrypted Provider Login    ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${discount2}=     FakerLibrary.word
    ${desc}=   FakerLibrary.word
    ${discountprice1}=     Random Int   min=50   max=100
    ${discountprice}=  Convert To Number  ${discountprice1}  1
    Set Test Variable   ${discountprice}
    ${resp}=   Create Discount  ${discount2}   ${desc}    ${discountprice}   ${calctype[1]}  ${disctype[0]}
    Log  ${resp.json()}
    Set Test Variable   ${discountId1}   ${resp.json()}   
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Discounts 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

      ${resp}=  Get Waitlist By Id  ${wid} 
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${fullAmount}  ${resp.json()['fullAmt']}   

    ${discAmt}=    Evaluate  ${fullAmount}-${discountprice}

    ${resp}=   Apply Service Level Discount for waitlist     ${wid}    ${discountId1}   ${discountprice}    ${EMPTY}    ${EMPTY}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['netRate']}                  ${discAmt}
    # Should Be Equal As Strings  ${resp.json()['billPaymentStatus']}         ${paymentStatus[0]}

    ${resp}=   Remove Service Level Discount for waitlist    ${wid}    ${discountId1}   ${discountprice}    ${EMPTY}    ${EMPTY}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['netRate']}                  ${fullAmount}
    Should Be Equal As Strings  ${resp.json()['billPaymentStatus']}         ${paymentStatus[0]}
  
JD-TC-RemoveServiceLevelDiscountforwaitlist-UH1

    [Documentation]   Remove service level discount for same waitlist and same discount.

    ${resp}=  Encrypted Provider Login    ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${discount1}=     FakerLibrary.word

    ${resp}=   Remove Service Level Discount for waitlist   ${wid}    ${discountId}   ${discountprice}    ${discount1}    ${discount1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}                  ${INCORRECT_DISCOUNT_ID}