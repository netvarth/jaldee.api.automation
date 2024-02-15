*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        JaldeeCoupon
Library           Collections
Library           String
Library           json
Library           requests
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/Keywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/SuperAdminKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py

***Keywords***

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

*** Variables ***

${SERVICE1}  Note Book1102
${SERVICE2}  boots102
${SERVICE3}  pen102
${SERVICE5}  boots13101
${queue1}  morning
${LsTime}   08:00 AM
${LeTime}   09:00 AM

${sTime}    09:00 PM
${eTime}    11:00 PM
${longi}        89.524764
${latti}        86.524764
${Coupon19}     Coupon1912
${numbers}  0123456789
${self}   0
*** Test Cases ***

JD-TC-provider_Coupon_with_diff_loc-1

    [Documentation]  Provider apply a coupon after waitlist with different locations

    ${PUSERPH0}=  Evaluate  ${PUSERNAME}+100110103
    Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${PUSERPH0}${\n}
    Set Suite Variable   ${PUSERPH0}
    ${resp}=   Run Keywords  clear_queue  ${PUSERPH0}   AND  clear_service  ${PUSERPH0}  AND  clear_Item    ${PUSERPH0}  AND   clear_Coupon   ${PUSERPH0}   AND  clear_Discount  ${PUSERPH0}  AND  clear_customer  ${PUSERPH0}
     
    ${licid}  ${licname}=  get_highest_license_pkg
    Log  ${licid}
    Log  ${licname}
    Set Suite Variable   ${licid}
    ${domresp}=  Get BusinessDomainsConf
    Log   ${domresp.json()}
    Should Be Equal As Strings  ${domresp.status_code}  200
    ${dlen}=  Get Length  ${domresp.json()}
    FOR  ${pos}  IN RANGE  ${dlen}  
        Set Suite Variable  ${d1}  ${domresp.json()[${pos}]['domain']}
        ${sd1}  ${check}=  Get Billable Subdomain  ${d1}  ${domresp}  ${pos}  
        Set Suite Variable   ${sd1}
        Exit For Loop IF     '${check}' == '${bool[1]}'
    END
    Log  ${d1}
    Log  ${sd1}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${d1}  ${sd1}  ${PUSERPH0}  ${licid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Account Activation  ${PUSERPH0}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  "${resp.json()}"    "true"
    
    ${resp}=  Account Set Credential  ${PUSERPH0}  ${PASSWORD}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Enable Waitlist
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list} 
    @{Views}=  Create List  self  all  customersOnly
    ${ph1}=  Evaluate  ${PUSERPH0}+1000000000
    ${ph2}=  Evaluate  ${PUSERPH0}+2000000000
    ${views}=  Evaluate  random.choice($Views)  random
    ${name1}=  FakerLibrary.name
    ${name2}=  FakerLibrary.name
    ${name3}=  FakerLibrary.name
    ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
    ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
    ${emails1}=  Emails  ${name3}  Email  ${P_Email}101.${test_mail}  ${views}
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
    
    ${resp}=  Update Business Profile with schedule  ${bs}  ${bs} Desc   ${companySuffix}  ${city}  ${longi}  ${latti}  www.${companySuffix}.com  free  True  Weekly  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}  ${EMPTY}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=  AddCustomer  ${CUSERNAME10}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()}

    ${description}=  FakerLibrary.sentence
    Set Suite Variable    ${description}
    ${city}=   FakerLibrary.City
    ${address} =  FakerLibrary.address
    ${postcode}=  FakerLibrary.postcode
    ${latti}  ${longi}  ${city}  ${country_abbr}  ${NZ_tz}=  FakerLibrary.Local Latlng  country_code=NZ  coords_only=False
    ${NZ_tz}=  db.get_Timezone_by_lat_long   ${latti}  ${longi}
    ${DAY1}=  db.get_date_by_timezone  ${NZ_tz}
    # ${sTime}  ${eTime}=  db.endtime_conversion  ${sTime}  ${eTime}
    ${parking}   Random Element   ${parkingType}
    ${24hours}    Random Element    ${bool}
    ${desc}=   FakerLibrary.sentence
    ${url}=   FakerLibrary.url
    ${sTime}=  db.get_time_by_timezone  ${NZ_tz}  
    ${eTime}=  db.add_timezone_time  ${NZ_tz}  0  30  

    ${resp}=  Create Location  ${city}  ${longi}  ${latti}  ${url}  ${postcode}  ${address}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${lid}  ${resp.json()}

    ${city2}=   FakerLibrary.City
    ${address2} =  FakerLibrary.address
    ${postcode2}=  FakerLibrary.postcode
    ${latti}  ${longi}  ${city2}  ${country_abbr}  ${US_tz_orig}=  FakerLibrary.Local Latlng  country_code=US  coords_only=False
    ${US_tz}=  db.get_Timezone_by_lat_long   ${latti}  ${longi}
    ${DAY2}=  db.get_date_by_timezone  ${US_tz}
    # ${sTime}  ${eTime}=  db.endtime_conversion  ${sTime}  ${eTime}
    ${parking}   Random Element   ${parkingType}
    ${24hours}    Random Element    ${bool}
    ${desc}=   FakerLibrary.sentence
    ${url}=   FakerLibrary.url
    ${sTime2}=  db.get_time_by_timezone  ${US_tz}  
    ${eTime2}=  db.add_timezone_time  ${US_tz}  0  30  

    ${resp}=  Create Location  ${city2}  ${longi}  ${latti}  ${url}  ${postcode}  ${address2}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY2}  ${EMPTY}  ${EMPTY}  ${sTime2}  ${eTime2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${lid2}  ${resp.json()}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    UpdateBaseLocation  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Create Service  ${SERVICE1}  ${description}   2  ${status[0]}  ${bType}  ${bool[1]}  ${notifytype[2]}  50  500  ${bool[1]}  ${bool[1]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id1}  ${resp.json()}

    ${coupon}=    FakerLibrary.word
    ${desc}=  FakerLibrary.Sentence   nb_words=2
    ${pc_amount}=   Random Int   min=10  max=50
    ${pc_amount}=  Convert To Number  ${pc_amount}  1
    Set Suite Variable  ${pc_amount}
    ${cupn_code}=   FakerLibrary.word
    Set Suite Variable  ${cupn_code}
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime}=  subtract_time  0  15
    # ${eTime}=  add_time   0  45
    # ${ST_DAY}=  db.get_date_by_timezone  ${tz}

    ${EN_DAY}=  db.add_timezone_date  ${NZ_tz}  10
    ${min_bill_amount}=   Random Int   min=90   max=100
    ${max_disc_val}=   Random Int   min=90  max=100
    ${max_prov_use}=   Random Int   min=10   max=20
    ${book_channel}=   Create List   ${bookingChannel[1]}    ${bookingChannel[0]}
    ${coupn_based}=  Create List   ${couponBasedOn[0]}
    ${tc}=  FakerLibrary.sentence
    ${services}=   Create list     ${s_id1}    

    ${resp}=  Create Provider Coupon   ${coupon}  ${desc}  ${pc_amount}  ${calctype[1]}  ${cupn_code}  ${recurringtype[1]}  ${list}  ${sTime}  ${eTime}  ${DAY1}  ${EN_DAY}  ${EMPTY}  ${bool[0]}  ${min_bill_amount}  ${max_disc_val}  ${bool[1]}  ${max_prov_use}  ${book_channel}  ${coupn_based}  ${tc}  services=${services}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${couponId}  ${resp.json()}

    ${resp}=  Get Coupons 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${coupon_code}  ${resp.json()[0]['couponCode']}

    ${sTime22}=  db.get_time_by_timezone  ${US_tz}  
    ${eTime22}=  db.add_timezone_time  ${US_tz}  0  30 

    ${resp}=  Create Queue  ${queue1}  ${recurringtype[1]}  ${list}  ${DAY2}  ${EMPTY}  ${EMPTY}  ${sTime22}  ${eTime22}  1  100  ${lid2}  ${s_id1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qid1}  ${resp.json()}

    ${des}=   FakerLibrary.sentence
    Set Suite Variable   ${des}
    
    ${resp}=  Add To Waitlist  ${cid}  ${s_id1}  ${qid1}  ${DAY2}  ${des}  ${bool[1]}  ${cid}  location=${lid2}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wid[0]}
    
    ${wid1}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid1}  ${wid1[0]}
    
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${bid}  ${resp.json()['id']}
    
    ${resp}=  Update Bill   ${wid}  addProviderCoupons   ${coupon_code}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

