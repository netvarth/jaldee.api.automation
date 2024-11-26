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
Resource          /ebs/TDD/SuperAdminKeywords.robot
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

*** Test Cases ***

JD-TC-ApplyJaldeeCouponforwaitlist-1
      [Documentation]   Apply Jaldee Coupon for waitlist then get the bill details.

    
    
    ${licid}  ${licname}=  get_highest_license_pkg
    Log  ${licid}
    Log  ${licname}
    
    ${firstname}  ${lastname}  ${PUSERPH0}  ${LoginId} =  Provider Signup   
    Set Suite Variable   ${PUSERPH0}

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}
    Set Suite Variable  ${account_id1}  ${resp.json()['id']}

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

    ${resp}=  Enable Waitlist
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

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

    # ${resp}=  Get BusinessDomainsConf
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${d1}  ${resp.json()[0]['domain']}
    # Set Test Variable  ${d2}  ${resp.json()[1]['domain']}
    # Set Test Variable  ${sd1}  ${resp.json()[0]['subDomains'][0]['subDomain']}
    # Set Test Variable  ${sd2}  ${resp.json()[0]['subDomains'][1]['subDomain']}
    # Set Test Variable  ${sd3}  ${resp.json()[1]['subDomains'][0]['subDomain']}
    # Set Test Variable  ${sd4}  ${resp.json()[1]['subDomains'][1]['subDomain']}
    # ${domains}=  Jaldee Coupon Target Domains  ${d1}  ${d2}
    # ${sub_domains}=  Jaldee Coupon Target SubDomains  ${d1}_${sd1}  ${d1}_${sd2}  ${d2}_${sd3}  ${d2}_${sd4}  
    # ${licenses}=  Jaldee Coupon Target License  ${licid}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1} 
    ${DAY2}=  db.add_timezone_date  ${tz}  10
    Set Suite Variable  ${DAY2}  

    # ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # ${cup_code}=   FakerLibrary.word
    # Set Suite Variable   ${cup_code}
    # ${cup_name}=    FakerLibrary.name
    # Set Suite Variable   ${cup_name}
    # ${cup_des}=    FakerLibrary.sentence
    # Set Suite Variable   ${cup_des}
    # ${c_des}=   FakerLibrary.sentence
    # Set Suite Variable   ${c_des}  
    # ${p_des}=    FakerLibrary.sentence
    # Set Suite Variable   ${p_des}
    # clear_jaldeecoupon     ${cup_code}
    # ${resp}=  Create Jaldee Coupon  ${cup_code}  ${cup_name}  ${cup_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  50  100  ${bool[0]}  ${bool[0]}  100  100  1000  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Push Jaldee Coupon  ${cup_code}  ${cup_des}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Get Jaldee Coupon By CouponCode   ${cup_code}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable    ${jaldee_amt}    ${resp.json()['discountValue']}  
    # ${resp}=  SuperAdmin Logout
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    # Log  ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}   200

    # ${resp}=  Enable Jaldee Coupon By Provider  ${cup_code}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # ${resp}=  Get Jaldee Coupons By Coupon_code  ${cup_code}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['couponState']}  ${couponState[1]}

    ${discount2}=     FakerLibrary.word
    ${desc}=   FakerLibrary.word
    ${discountprice1}=     Random Int   min=5   max=10
    ${discountprice}=  Convert To Number  ${discountprice1}  1
    Set Suite Variable   ${discountprice}
    ${resp}=   Create Discount  ${discount2}   ${desc}    ${discountprice}   ${calctype[1]}  ${disctype[0]}
    Log  ${resp.json()}
    Set Suite Variable   ${discountId1}   ${resp.json()}   
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Discounts 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${netRate}=    Evaluate  ${fullAmount}-50

    ${resp}=   Apply Jaldee Coupon for waitlist    ${wid}    ${cup_code}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['netTotal']}                  ${fullAmount}
    Should Be Equal As Strings  ${resp.json()['billPaymentStatus']}         ${paymentStatus[0]}
    Should Be Equal As Strings  ${resp.json()['netRate']}                  ${netRate}
    Should Be Equal As Strings  ${resp.json()['amountDue']}                  ${netRate}

    ${resp}=   Get Waitlist level Bill Details      ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-ApplyJaldeeCouponforwaitlist-UH1
      [Documentation]  Get bill details with invalid waitlist id.

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${wid}=   FakerLibrary.word

    ${resp}=   Get Waitlist level Bill Details      ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-ApplyJaldeeCouponforwaitlist-UH2
      [Documentation]  Get bill details using another provider login.

    ${resp}=   Encrypted Provider Login  ${PUSERNAME8}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200


    ${resp}=   Get Waitlist level Bill Details      ${wid} 
    Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  401
      Should Be Equal As Strings  "${resp.json()}"  "${NO_PERMISSION}"  

JD-TC-ApplyJaldeeCouponforwaitlist-UH3
      [Documentation]  Get bill details withoout login.

    ${resp}=   Get Waitlist level Bill Details      ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"    "${SESSION_EXPIRED}" 