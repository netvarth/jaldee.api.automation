*** Settings ***

Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Bill
Library           Collections
Library           String
Library           json
Library           requests
Library           FakerLibrary
Library           Process
Library           OperatingSystem
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/musers.py

*** Variables ***

${coupon1}   COUPON1
${discount1}   DISCOUNT1
${item1}    ITEM1
${itemCode1}   itemCode1
${SERVICE1}   SERVICE1
${DisplayName1}   item1_DisplayName

*** Test Cases ***

JD-TC-Get Bill By UUId -1

        [Documentation]   Get Bill by UUId for valid provider
        ${domresp}=  Get BusinessDomainsConf
        Should Be Equal As Strings  ${domresp.status_code}  200

        ${dlen}=  Get Length  ${domresp.json()}
        FOR  ${pos}  IN RANGE  ${dlen}  
        Set Test Variable  ${domain}  ${domresp.json()[${pos}]['domain']}

        ${subdomain}=  Get Billable Subdomain  ${domain}  ${domresp}  ${pos}  
        Set Test Variable   ${subdomain}
        Exit For Loop IF    '${subdomain}'

        END
        ${firstname}=  FakerLibrary.name
        ${lastname}=  FakerLibrary.last_name
        ${PUSERNAME_Z}=  Evaluate  ${PUSERNAME}+31481             
        Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERNAME_Z}${\n}
        ${pkg_id}=   get_highest_license_pkg
        ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${domain}  ${subdomain}  ${PUSERNAME_Z}   ${pkg_id[0]}
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200
        ${resp}=  Account Activation  ${PUSERNAME_Z}  0
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200
        ${resp}=  Account Set Credential  ${PUSERNAME_Z}  ${PASSWORD}  0
        Should Be Equal As Strings    ${resp.status_code}    200
        Set Suite Variable  ${PUSERNAME_Z}
        ${resp}=  Encrypted Provider Login  ${PUSERNAME_Z}  ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200 


        #${dis}   ${service_duration[2]}  ${status[0]}  ${btype}   ${bool[1]}   ${notifytype[2]}   0  500  ${bool[0]}  ${bool[1]}
        ${desc}=  FakerLibrary.sentence  nb_words=2  variable_nb_words=False
        set Suite Variable   ${desc}
        ${ser_durtn}=   Random Int   min=2   max=10
        Set Suite Variable   ${ser_durtn}
        ${ser_amount}=   Random Int   min=100   max=1000
        ${ser_amount}=   Convert To Number   ${ser_amount}
        Set Suite Variable   ${ser_amount}
        ${resp}=  Create Service  ${SERVICE1}  ${desc}   ${ser_durtn}   ${status[0]}  ${btype}   ${bool[1]}   ${notifytype[2]}  ${EMPTY}  ${ser_amount}  ${bool[0]}  ${bool[1]}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${sid1}  ${resp.json()}
        ${list}=  Create List  1  2  3  4  5  6  7
        ${PUSERPH4}=  Evaluate  ${PUSERNAME}+305
        Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERPH4}${\n}
        ${PUSERPH5}=  Evaluate  ${PUSERNAME}+306
        Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERPH5}${\n}
        ${PUSERMAIL3}=   Set Variable  ${P_Email}${PUSERPH4}.${test_mail}
        ${views}=  Evaluate  random.choice($Views)  random
        ${name1}=  FakerLibrary.name
        ${name2}=  FakerLibrary.name
        ${name3}=  FakerLibrary.name
        ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${PUSERPH4}  ${views}
        ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${PUSERPH5}  ${views}
        ${emails1}=  Emails  ${name3}  Email  ${PUSERMAIL3}  ${views}
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
        # ${sTime}=  db.get_time_by_timezone  ${tz}
        ${sTime}=  db.get_time_by_timezone  ${tz}
        ${eTime}=  add_timezone_time  ${tz}  0  15  
        ${desc}=   FakerLibrary.sentence  nb_words=2  variable_nb_words=False
        ${url}=   FakerLibrary.url
        ${parking}   Random Element   ${parkingType}
        ${DAY}=  db.get_date_by_timezone  ${tz}
        Set Suite Variable   ${DAY}
        ${resp}=  Update Business Profile with schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${bool[1]}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}  ${EMPTY}
        Should Be Equal As Strings    ${resp.status_code}    200
        Set Test Variable  ${lid}  ${resp.json()['baseLocation']['id']}
        ${fields}=   Get subDomain level Fields  ${domain}  ${subdomain}
        Should Be Equal As Strings    ${fields.status_code}   200
        ${virtual_fields}=  get_Subdomainfields  ${fields.json()}
        ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${subdomain}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp}=  Get specializations Sub Domain  ${domain}  ${subdomain}
        Should Be Equal As Strings    ${resp.status_code}   200
        ${spec}=  get_Specializations  ${resp.json()}
        ${resp}=  Update Specialization  ${spec}
        Should Be Equal As Strings    ${resp.status_code}   200
        ${resp}=  Enable Waitlist
        Should Be Equal As Strings  ${resp.status_code}  200 
        ${resp}=  Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[1]}  ${boolean[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${GST_num}  ${pan_num}=  db.Generate_gst_number  ${Container_id}
        ${gstper}=  Random Element  ${gstpercentage}
        ${resp}=  Update Tax Percentage  ${gstper}  ${GST_num}
        Should Be Equal As Strings    ${resp.status_code}   200
        ${resp}=  Enable Tax
        Should Be Equal As Strings    ${resp.status_code}   200
        ${capacity}=   Random Int   min=20   max=100
        ${parallel}=   Random Int   min=1   max=2
        ${sTime}=  add_timezone_time  ${tz}  1  30  
        ${eTime}=  add_timezone_time  ${tz}  3  00  
        ${queue1}=   FakerLibrary.word
        ${resp}=  Create Queue  ${queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${parallel}  ${capacity}  ${lid}  ${sid1}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable   ${qid1}   ${resp.json()}

        ${resp}=  AddCustomer  ${CUSERNAME9}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${cid}  ${resp.json()}   
        ${resp}=  Add To Waitlist  ${cid}  ${sid1}  ${qid1}  ${DAY}  ${desc}  ${bool[1]}  ${cid}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Suite Variable  ${wid}  ${wid[0]}
        
        ${resp}=  Get Bill By UUId  ${wid}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${bid}  ${resp.json()['id']}
        ${it_amount}=   Random Int   min=100   max=1000
        ${it_amount}=   Convert To Number   ${it_amount}
        ${des}=  FakerLibrary.word
        # ${resp}=  Create Item   ${item1}   ${des}  ${des}  ${it_amount}  ${bool[1]} 
        ${resp}=  Create Sample Item   ${DisplayName1}   ${item1}  ${itemCode1}  ${it_amount}  ${bool[1]}          
        Should Be Equal As Strings  ${resp.status_code}   200
        Set Test Variable  ${itemId}  ${resp.json()}

        ${tamount}=  Evaluate  ${ser_amount}/2
        ${tamount}=   Convert To Integer   ${tamount}

        # ${cou_amount}=   Random Int   min=1   max=${tamount}
        # ${cou_amount}=   Convert To Number   ${cou_amount}
        
        # ${resp}=  Create Coupon  ${coupon1}  ${desc}  ${cou_amount}  ${calctype[1]}
        # Should Be Equal As Strings  ${resp.status_code}  200
        # Set Test Variable   ${couponId}   ${resp.json()}

        ${coupon}=    FakerLibrary.word
        ${desc}=  FakerLibrary.Sentence   nb_words=2
        ${cou_amount}=   Random Int   min=1   max=${tamount}
        ${cou_amount}=   Convert To Number   ${cou_amount}
        ${cupn_code}=   FakerLibrary.word
        ${list}=  Create List  1  2  3  4  5  6  7
        ${sTime}=  db.subtract_timezone_time  ${tz}  0  15
        ${eTime}=  add_timezone_time  ${tz}  0  45  
        ${ST_DAY}=  db.get_date_by_timezone  ${tz}
        ${EN_DAY}=  db.add_timezone_date  ${tz}   10
        ${min_bill_amount}=   Random Int   min=10   max=100
        ${max_disc_val}=   Random Int   min=100   max=500
        ${max_prov_use}=   Random Int   min=10   max=20
        ${book_channel}=   Create List   ${bookingChannel[0]}
        ${coupn_based}=  Create List   ${couponBasedOn[0]}
        ${tc}=  FakerLibrary.sentence
        ${services}=   Create list   ${sid1}  
        ${items}=   Create list   ${itemId}  
        ${resp}=  Create Provider Coupon   ${coupon}  ${desc}  ${cou_amount}  ${calctype[1]}  ${cupn_code}  ${recurringtype[1]}  ${list}  ${sTime}  ${eTime}  ${ST_DAY}  ${EN_DAY}  ${EMPTY}  ${bool[1]}  ${min_bill_amount}  ${max_disc_val}  ${bool[1]}  ${max_prov_use}  ${book_channel}  ${coupn_based}  ${tc}  services=${services}  items=${items} 
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${couponId}  ${resp.json()}


        ${dis_amount}=   Random Int   min=1   max=${tamount}
        ${dis_amount}=   Convert To Number   ${dis_amount}
        ${resp}=   Create Discount  ${discount1}   ${desc}    ${dis_amount}   ${calctype[1]}  ${disctype[0]}
        Set Test Variable   ${discountId}   ${resp.json()}   
        Should Be Equal As Strings  ${resp.status_code}  200
        
        # ${coupon}=  Provider Coupons  ${bid}  ${couponId}
        ${resp}=  Update Bill   ${wid}  ${action[12]}   ${cupn_code}
        Should Be Equal As Strings  ${resp.status_code}  200
        
        ${item}=  Item Bill  ${desc}  ${itemId}  1
        ${resp}=  Update Bill   ${wid}  addItem   ${item}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${disc1}=  Bill Discount Input  ${discountId}  ${des}  ${desc}
        ${bdisc}=  Bill Discount  ${bid}  ${disc1}   
        
        ${resp}=  Update Bill   ${wid}  addBillLevelDiscount  ${bdisc}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${netTotal}=  Evaluate  ${ser_amount}+${it_amount}
        ${netTotal}=  Convert To Number  ${netTotal}  2
        ${taxable}=  Evaluate  ${netTotal}-${cou_amount}-${dis_amount}
        ${taxable}=  Convert To Number  ${taxable}  2
        ${taxamnt}=  Evaluate  ${taxable}* ${gstper}/100
        ${taxamnt}=  Convert To Number  ${taxamnt}  2
        ${netrate}=  Evaluate  ${taxable}+${taxamnt}
        ${netrate}=  Convert To Number  ${netrate}  2
        ${resp}=  Get Bill By UUId  ${wid}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  uuid=${wid}  netTotal=${netTotal}  billStatus=New  billViewStatus=Notshow  netRate=${netrate}  billPaymentStatus=NotPaid  totalAmountPaid=0.0  amountDue=${netrate}  taxableTotal=${taxable}  totalTaxAmount=${taxamnt}  taxPercentage=${gstper}
        Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${sid1}
        Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE1}  
        Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
        Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}   ${gstper} 
        Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  ${ser_amount}
        Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}  ${ser_amount}
        Should Be Equal As Strings  ${resp.json()['items'][0]['itemId']}  ${itemId}  
        Should Be Equal As Strings  ${resp.json()['items'][0]['price']}  ${it_amount}
        Should Be Equal As Strings  ${resp.json()['items'][0]['itemName']}  ${DisplayName1}  
        Should Be Equal As Strings  ${resp.json()['items'][0]['quantity']}  1.0
        Should Be Equal As Strings  ${resp.json()['items'][0]['reason']}  ${desc}  
        Should Be Equal As Strings  ${resp.json()['items'][0]['GSTpercentage']}   ${gstper}
        Should Be Equal As Strings  ${resp.json()['discount'][0]['id']}  ${discountId}    
        Should Be Equal As Strings  ${resp.json()['discount'][0]['name']}  ${discount1} 
        Should Be Equal As Strings  ${resp.json()['discount'][0]['discValue']}  ${dis_amount} 
        Should Be Equal As Strings  ${resp.json()['discount'][0]['displayNote']}  ${desc}
        Should Be Equal As Strings  ${resp.json()['discount'][0]['privateNote']}  ${des}  
        Should Be Equal As Strings  ${resp.json()['discount'][0]['calculationType']}  ${calctype[1]}
        Should Be Equal As Strings  ${resp.json()['providerCoupon']['${cupn_code}']['value']}  ${cou_amount}  

        # Should Be Equal As Strings  ${resp.json()['providerCoupon'][0]['id']}  ${couponId}  
        # Should Be Equal As Strings  ${resp.json()['providerCoupon'][0]['couponValue']}  ${cou_amount} 
        # Should Be Equal As Strings  ${resp.json()['providerCoupon'][0]['name']}  ${coupon1}


JD-TC-Get Bill By UUId -UH1

        [Documentation]    Get bill Bill by UUId  using another provider's uuid
        ${resp}=  Encrypted Provider Login  ${PUSERNAME4}  ${PASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp}=  Get Bill By UUId  ${wid}
        Should Be Equal As Strings  ${resp.status_code}  401
        Should Be Equal As Strings  "${resp.json()}"  "${YOU_CANNOT_VIEW_THE_BILL}"

JD-TC-Get Bill By UUId -UH2

        [Documentation]  Consumer check to Get Bill By UUId
        ${resp}=   ConsumerLogin  ${CUSERNAME9}  ${PASSWORD} 
        Should Be Equal As Strings    ${resp.status_code}   200 
        ${resp}=  Get Bill By UUId  ${wid}  
        Should Be Equal As Strings  ${resp.status_code}  401
        Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}" 

JD-TC-Get Bill By UUId -UH3 

        [Documentation]   without login to Get Bill By UUId
        ${resp}=  Get Bill By UUId  ${wid}    
        Should Be Equal As Strings  ${resp.status_code}  419
        Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}" 

JD-TC-Get Bill By UUId -2

        [Documentation]   consumer takes checkin for self and family members
        ...    Get Bill, cancel consumer waitlist, Get bill and check bill parent id
        ...    cancel waitlist of next family member and get bill 

        ${resp}=  Consumer Login  ${CUSERNAME9}  ${PASSWORD}
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200
        Set Test Variable  ${jdconID}   ${resp.json()['id']}
        Set Test Variable  ${firstName}   ${resp.json()['firstName']}
        Set Test Variable  ${lastName}   ${resp.json()['lastName']}

        ${resp}=  Consumer Logout
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

        ${resp}=   Get File    /ebs/TDD/varfiles/musers.py
        ${len}=   Split to lines  ${resp}
        ${length}=  Get Length   ${len}
        ${max_party}=  get_maxpartysize_subdomain
        Log    ${max_party}
        Set Test Variable  ${d1}  ${max_party['domain']}
        Set Test Variable  ${sd1}  ${max_party['subdomain']}
        
        FOR   ${a}  IN RANGE    ${length}    
                ${resp}=  Encrypted Provider Login  ${MUSERNAME${a}}  ${PASSWORD}
                Should Be Equal As Strings    ${resp.status_code}    200
                ${domain}=   Set Variable    ${resp.json()['sector']}
                ${subdomain}=    Set Variable      ${resp.json()['subSector']}
                ${resp}=  View Waitlist Settings
                Log   ${resp.json()}
                Should Be Equal As Strings    ${resp.status_code}    200
                Continue For Loop If  '${resp.json()['maxPartySize']}' == '1'
                Run Keyword If  ${resp.json()['filterByDept']}==${bool[1]}   Toggle Department Disable  
                Exit For Loop If     '${resp.json()['maxPartySize']}' > '1'  
                # Exit For Loop If  '${domain}' == '${d1}' and '${subdomain}' == '${sd1}'
        END
        Set Suite Variable  ${a}
        Run Keyword If  ${resp.json()['filterByDept']}==${bool[1]}   Toggle Department Disable
        # ${resp}=  Encrypted Provider Login  ${PUSERNAME${a}}  ${PASSWORD}
        # Log  ${resp.json()}
        # Should Be Equal As Strings    ${resp.status_code}    200 

        clear_queue      ${MUSERNAME${a}}
        clear_location   ${MUSERNAME${a}}
        clear_service    ${MUSERNAME${a}}
        clear_customer   ${MUSERNAME${a}}

        ${resp}=  Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${boolean[0]}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
    
        ${resp}=  Get jaldeeIntegration Settings
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}

       
        ${resp}=  AddCustomer  ${CUSERNAME9}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${cid}  ${resp.json()}   
        # Set Test Variable  ${firstName}  ${resp.json()[0]['firstName']}

        ${resp}=  Create Sample Queue
        Set Test Variable  ${qid1}   ${resp['queue_id']}
        Set Test Variable  ${sid1}   ${resp['service_id']}
        Set Test Variable  ${lid}   ${resp['location_id']}
        Set Test Variable  ${s_name}   ${resp['service_name']}

        ${resp}=   Get Location ById  ${lid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}

        # ${resp}=   Get Service
        # Log   ${resp.json()}
        # Should Be Equal As Strings  ${resp.status_code}  200
        # Should Be Equal As Strings  ${resp.json()[0]['id']}   ${sid1}
        # Set Test Variable   ${service_charge}   ${resp.json()[0]['totalAmount']}
        ${resp}=   Get Service By Id  ${sid1}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable   ${service_charge}   ${resp.json()['totalAmount']}

        ${resp}=    Get Locations
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()[0]['id']}   ${lid}
        # Set Test Variable   ${lid1}   ${resp.json()[0]['id']}

        FOR  ${i}  IN RANGE  1   4
        
                ${firstname}=  FakerLibrary.first_name
                Set Test Variable  ${firstname${i}}  ${firstname}
                ${lastname}=  FakerLibrary.last_name
                Set Test Variable  ${lastname${i}}  ${lastname}
                ${dob}=  FakerLibrary.Date
                Set Test Variable  ${dob${i}}  ${dob}
                ${gender}=   Random Element    ${Genderlist}
                Set Test Variable  ${gender${i}}  ${gender}
                ${resp}=  AddFamilyMemberByProvider   ${cid}  ${firstname${i}}  ${lastname${i}}  ${dob${i}}  ${gender${i}}
                Log  ${resp.json()}
                Should Be Equal As Strings  ${resp.status_code}  200
                Set Test Variable  ${mem_id${i}}  ${resp.json()}
        
        END

        ${resp}=  Add To Waitlist  ${cid}  ${sid1}  ${qid1}  ${DAY}  ${desc}  ${bool[1]}  ${cid}  ${mem_id1}  ${mem_id2}   ${mem_id3}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        
        ${json} =  Set Variable  ${resp.json()}
        ${wl_id}=  Get Dictionary Values  ${resp.json()}
        Set Test Variable  ${wait_id1}  ${wl_id[0]}
        Set Test Variable  ${wait_id2}  ${wl_id[1]}
        Set Test Variable  ${wait_id3}  ${wl_id[2]}
        Set Test Variable  ${wait_id4}  ${wl_id[3]}

        ${resp}=  Get Waitlist By Id  ${wait_id1}
        Log  ${resp.json()} 
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  ynwUuid=${wait_id1}    date=${DAY}  waitlistStatus=${wl_status[1]}  partySize=1   waitlistedBy=${waitlistedby[1]}  personsAhead=0
        Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${s_id1}
        Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid}
        Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid}

        ${resp}=  Get Waitlist By Id  ${wait_id2}
        Log  ${resp.json()} 
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  ynwUuid=${wait_id2}    date=${DAY}  waitlistStatus=${wl_status[1]}  partySize=1   waitlistedBy=${waitlistedby[1]}  personsAhead=1
        Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${s_id1}
        Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid}
        Should Be Equal As Strings  ${resp.json()['parentUuid']}                      ${wait_id1}
        Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${mem_id1}

        ${resp}=  Get Waitlist By Id  ${wait_id3}
        Log  ${resp.json()} 
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  ynwUuid=${wait_id3}    date=${DAY}  waitlistStatus=${wl_status[1]}  partySize=1   waitlistedBy=${waitlistedby[1]}  personsAhead=2
        Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${s_id1}
        Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid}
        Should Be Equal As Strings  ${resp.json()['parentUuid']}                      ${wait_id1}
        Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${mem_id2}

        ${resp}=  Get Waitlist By Id  ${wait_id4}
        Log  ${resp.json()} 
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  ynwUuid=${wait_id4}    date=${DAY}  waitlistStatus=${wl_status[1]}  partySize=1   waitlistedBy=${waitlistedby[1]}  personsAhead=3
        Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${s_id1}
        Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid}
        Should Be Equal As Strings  ${resp.json()['parentUuid']}                      ${wait_id1}
        Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${mem_id3}

        ${netRate}=   Evaluate   ${service_charge}*4

        ${resp}=  Get Bill By UUId  ${wait_id1}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()['uuid']}         ${wait_id1}
        Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}         ${netRate}
        Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}         4.0
        
        ${resp}=  Get Bill By UUId  ${wait_id2}
        Should Be Equal As Strings  ${resp.status_code}  422
        Should Be Equal As Strings  "${resp.json()}"   "${CANNOT_CREATE_BILL}"

        ${msg}=  Fakerlibrary.word
        ${resp}=  Waitlist Action Cancel  ${wait_id1}  ${waitlist_cancl_reasn[4]}  ${msg}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=  Get Waitlist By Id  ${wait_id1}
        Log  ${resp.json()} 
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  ynwUuid=${wait_id1}    date=${DAY}  waitlistStatus=${wl_status[4]}  waitlistedBy=${waitlistedby[1]}
        # Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${s_id1}
        # Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid}
        # Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${self}

        ${resp}=  Get Waitlist By Id  ${wait_id2}
        Log  ${resp.json()} 
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  ynwUuid=${wait_id2}    date=${DAY}  waitlistStatus=${wl_status[1]}  waitlistedBy=${waitlistedby[1]}  personsAhead=0
        Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${s_id1}
        Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid}
        Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${mem_id1}
        Should Not Contain   ${resp.json()}  parentUuid

        ${resp}=  Get Waitlist By Id  ${wait_id3}
        Log  ${resp.json()} 
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  ynwUuid=${wait_id3}    date=${DAY}  waitlistStatus=${wl_status[1]}  waitlistedBy=${waitlistedby[1]}  personsAhead=1
        Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${s_id1}
        Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid}
        Should Be Equal As Strings  ${resp.json()['parentUuid']}                      ${wait_id2}
        Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${mem_id2}

        ${resp}=  Get Waitlist By Id  ${wait_id4}
        Log  ${resp.json()} 
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  ynwUuid=${wait_id4}    date=${DAY}  waitlistStatus=${wl_status[1]}  waitlistedBy=${waitlistedby[1]}  personsAhead=2
        Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${s_id1}
        Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid}
        Should Be Equal As Strings  ${resp.json()['parentUuid']}                      ${wait_id2}
        Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${mem_id3}

        ${resp}=  Get Bill By UUId  ${wait_id1}
        Should Be Equal As Strings  ${resp.status_code}  422
        Should Be Equal As Strings  "${resp.json()}"   "${CANCELLED_WAITLIST}"

        ${netRate}=   Evaluate   ${service_charge}*3

        ${resp}=  Get Bill By UUId  ${wait_id2}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()['uuid']}         ${wait_id2}
        Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}         ${netRate}
        Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}         3.0

        ${msg}=  Fakerlibrary.word
        ${resp}=  Waitlist Action Cancel  ${wait_id2}  ${waitlist_cancl_reasn[4]}  ${msg}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=  Get Waitlist By Id  ${wait_id1}
        Log  ${resp.json()} 
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  ynwUuid=${wait_id1}    date=${DAY}  waitlistStatus=${wl_status[4]}  waitlistedBy=${waitlistedby[1]}

        ${resp}=  Get Waitlist By Id  ${wait_id2}
        Log  ${resp.json()} 
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  ynwUuid=${wait_id2}    date=${DAY}  waitlistStatus=${wl_status[4]}  waitlistedBy=${waitlistedby[1]}  

        ${resp}=  Get Waitlist By Id  ${wait_id3}
        Log  ${resp.json()} 
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  ynwUuid=${wait_id3}    date=${DAY}  waitlistStatus=${wl_status[1]}  waitlistedBy=${waitlistedby[1]}  personsAhead=0
        Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${s_id1}
        Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid}
        Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${mem_id2}
        Should Not Contain   ${resp.json()}  parentUuid

        ${resp}=  Get Waitlist By Id  ${wait_id4}
        Log  ${resp.json()} 
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  ynwUuid=${wait_id4}    date=${DAY}  waitlistStatus=${wl_status[1]}  waitlistedBy=${waitlistedby[1]}  personsAhead=1
        Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${s_id1}
        Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid}
        Should Be Equal As Strings  ${resp.json()['parentUuid']}                      ${wait_id3}
        Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${mem_id3}

        ${resp}=  Get Bill By UUId  ${wait_id2}
        Should Be Equal As Strings  ${resp.status_code}  422
        Should Be Equal As Strings  "${resp.json()}"   "${CANCELLED_WAITLIST}"

        ${netRate}=   Evaluate   ${service_charge}*2

        sleep   2s
        ${resp}=  Get Bill By UUId  ${wait_id3}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()['uuid']}         ${wait_id3}
        Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}         ${netRate}
        Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}         2.0

        ${msg}=  Fakerlibrary.word
        ${resp}=  Waitlist Action Cancel  ${wait_id3}  ${waitlist_cancl_reasn[4]}  ${msg}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=  Get Waitlist By Id  ${wait_id1}
        Log  ${resp.json()} 
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  ynwUuid=${wait_id1}    date=${DAY}  waitlistStatus=${wl_status[4]}  waitlistedBy=${waitlistedby[1]}

        ${resp}=  Get Waitlist By Id  ${wait_id2}
        Log  ${resp.json()} 
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  ynwUuid=${wait_id2}    date=${DAY}  waitlistStatus=${wl_status[4]}  waitlistedBy=${waitlistedby[1]}  

        ${resp}=  Get Waitlist By Id  ${wait_id3}
        Log  ${resp.json()} 
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  ynwUuid=${wait_id3}    date=${DAY}  waitlistStatus=${wl_status[4]}  waitlistedBy=${waitlistedby[1]}


        ${resp}=  Get Waitlist By Id  ${wait_id4}
        Log  ${resp.json()} 
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  ynwUuid=${wait_id4}    date=${DAY}  waitlistStatus=${wl_status[1]}  waitlistedBy=${waitlistedby[1]}  personsAhead=0
        Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${s_id1}
        Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid}
        Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${mem_id3}
        Should Not Contain   ${resp.json()}  parentUuid

        ${resp}=  Get Bill By UUId  ${wait_id3}
        Should Be Equal As Strings  ${resp.status_code}  422
        Should Be Equal As Strings  "${resp.json()}"   "${CANCELLED_WAITLIST}"

        # ${netRate}=   Evaluate ${service_charge}*2

        ${resp}=  Get Bill By UUId  ${wait_id4}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()['uuid']}         ${wait_id4}
        Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}         ${service_charge}
        Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}         1.0


JD-TC-Get Bill By UUId -3

        [Documentation]   consumer takes appointment for self and family members
        ...    Get Bill, cancel consumer appointment, Get bill and check bill parent id
        ...    cancel appointment of next family member and get bill 

        # ${resp}=  Consumer Login  ${CUSERNAME9}  ${PASSWORD}
        # Log   ${resp.json()}
        # Should Be Equal As Strings    ${resp.status_code}    200
        # Set Test Variable  ${jdconID}   ${resp.json()['id']}
        # Set Test Variable  ${Con_firstName}   ${resp.json()['firstName']}
        # Set Test Variable  ${Con_lastName}   ${resp.json()['lastName']}

        # ${resp}=  Consumer Logout
        # Log   ${resp.json()}
        # Should Be Equal As Strings    ${resp.status_code}    200

        ${resp}=  Encrypted Provider Login  ${MUSERNAME${a}}  ${PASSWORD}
        Should Be Equal As Strings    ${resp.status_code}    200

        ${resp}=  Get Consumer By Id  ${CUSERNAME9}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${jdconID}   ${resp.json()['id']}
        Set Test Variable  ${Con_firstName}   ${resp.json()['userProfile']['firstName']}
        Set Test Variable  ${Con_lastName}   ${resp.json()['userProfile']['lastName']}

        clear_service   ${MUSERNAME${a}}
        clear_location  ${MUSERNAME${a}}
        clear_queue      ${MUSERNAME${a}}
        clear_appt_schedule   ${MUSERNAME${a}}
        clear_customer   ${MUSERNAME${a}}

        ${resp}=   Get Appointment Settings
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Run Keyword If  ${resp.json()['enableAppt']}==${bool[0]}   Enable Appointment

        ${lid}=  Create Sample Location
        Set Test Variable   ${lid}

        ${DAY1}=  db.get_date_by_timezone  ${tz}
        Set Suite Variable  ${DAY1} 
        ${DAY2}=  db.add_timezone_date  ${tz}  10        
        Set Suite Variable  ${DAY2} 
        ${list}=  Create List  1  2  3  4  5  6  7
        Set Suite Variable  ${list} 
        ${sTime1}=  add_timezone_time  ${tz}  0  15  
        Set Suite Variable   ${sTime1}
        ${delta}=  FakerLibrary.Random Int  min=10  max=60
        Set Suite Variable  ${delta}
        ${eTime1}=  add_two   ${sTime1}  ${delta}
        Set Suite Variable   ${eTime1}
        
        ${s_name}=  FakerLibrary.name
        ${s_id}=  Create Sample Service  ${s_name}
        ${schedule_name}=  FakerLibrary.bs
        Set Suite Variable  ${schedule_name}
        ${parallel}=  FakerLibrary.Random Int  min=1  max=10
        ${maxval}=  Convert To Integer   ${delta/4}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
        ${bool1}=  Random Element  ${bool}
        ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}  
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${sch_id}  ${resp.json()}

        # ${resp}=  Create Sample Schedule
        # Set Test Variable  ${sch_id}   ${resp['schedule_id']}
        # Set Test Variable  ${s_id}   ${resp['service_id']}
        # Set Test Variable  ${lid}   ${resp['location_id']}
        # Set Test Variable  ${s_name}   ${resp['service_name']}

        ${resp}=  Get Appointment Schedule ById  ${sch_id}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  id=${sch_id}  apptState=${Qstate[0]}

        ${resp}=  AddCustomer  ${CUSERNAME9}   firstName=${Con_firstName}   lastName=${Con_lastName}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${cid}  ${resp.json()}   
        FOR  ${i}  IN RANGE  1   4
        
                ${firstname}=  FakerLibrary.first_name
                Set Test Variable  ${firstname${i}}  ${firstname}
                ${lastname}=  FakerLibrary.last_name
                Set Test Variable  ${lastname${i}}  ${lastname}
                ${dob}=  FakerLibrary.Date
                Set Test Variable  ${dob${i}}  ${dob}
                ${gender}=   Random Element    ${Genderlist}
                Set Test Variable  ${gender${i}}  ${gender}
                ${resp}=  AddFamilyMemberByProvider   ${cid}  ${firstname${i}}  ${lastname${i}}  ${dob${i}}  ${gender${i}}
                Log  ${resp.json()}
                Should Be Equal As Strings  ${resp.status_code}  200
                Set Test Variable  ${mem_id${i}}  ${resp.json()}
        
        END

        ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  scheduleId=${sch_id}
        Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
        Set Test Variable   ${slot2}   ${resp.json()['availableSlots'][1]['time']}
        Set Test Variable   ${slot3}   ${resp.json()['availableSlots'][2]['time']}
        Set Test Variable   ${slot4}   ${resp.json()['availableSlots'][3]['time']}

        ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
        ${apptfor2}=  Create Dictionary  id=${mem_id1}   apptTime=${slot2}
        ${apptfor3}=  Create Dictionary  id=${mem_id2}   apptTime=${slot3}
        ${apptfor4}=  Create Dictionary  id=${mem_id3}   apptTime=${slot4}
        ${apptfor}=   Create List  ${apptfor1}  ${apptfor2}  ${apptfor3}  ${apptfor4}

        ${cnote}=   FakerLibrary.word
        ${resp}=  Take Appointment For Consumer   ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        
        ${Keys}=  Get Dictionary Keys  ${resp.json()}   sort_keys=False 
        ${apptid1}=  Get From Dictionary  ${resp.json()}  ${Con_firstName}
        ${apptid2}=  Get From Dictionary  ${resp.json()}  ${firstName1}
        ${apptid3}=  Get From Dictionary  ${resp.json()}  ${firstName2}
        ${apptid4}=  Get From Dictionary  ${resp.json()}  ${firstName3}

        FOR  ${i}  IN RANGE  1   5

                ${resp}=  Get Appointment EncodedID   ${apptid${i}}
                Log   ${resp.json()}
                Should Be Equal As Strings  ${resp.status_code}  200
                ${encId}=   Set Variable   ${resp.json()}
                Set Test Variable  ${encId${i}}  ${encId}

        END

        ${resp}=  Get Appointment By Id   ${apptid1}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  uid=${apptid1}  appointmentEncId=${encId1}  appmtDate=${DAY1}  appmtTime=${slot1}  apptBy=PROVIDER   paymentStatus=${paymentStatus[0]}  appointmentMode=${appointmentMode[0]}  apptStatus=${apptStatus[1]}

        ${resp}=  Get Appointment By Id   ${apptid2}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  uid=${apptid2}  appointmentEncId=${encId2}  appmtDate=${DAY1}  appmtTime=${slot2}  apptBy=PROVIDER   paymentStatus=${paymentStatus[0]}  appointmentMode=${appointmentMode[0]}  apptStatus=${apptStatus[1]}

        ${resp}=  Get Appointment By Id   ${apptid3}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  uid=${apptid3}  appointmentEncId=${encId3}  appmtDate=${DAY1}  appmtTime=${slot3}  apptBy=PROVIDER   paymentStatus=${paymentStatus[0]}  appointmentMode=${appointmentMode[0]}  apptStatus=${apptStatus[1]}

        ${resp}=  Get Appointment By Id   ${apptid4}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  uid=${apptid4}  appointmentEncId=${encId4}  appmtDate=${DAY1}  appmtTime=${slot4}  apptBy=PROVIDER   paymentStatus=${paymentStatus[0]}  appointmentMode=${appointmentMode[0]}  apptStatus=${apptStatus[1]}

        ${resp}=   Get Service
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()[0]['id']}   ${s_id}
        Set Test Variable   ${service_charge}   ${resp.json()[0]['totalAmount']}

        ${netRate}=   Evaluate   ${service_charge}*4
        
        ${resp}=  Get Bill By UUId  ${apptid1}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()['uuid']}         ${apptid1}
        Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}         ${netRate}
        Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}         4.0

        ${resp}=  Get Bill By UUId  ${apptid2}
        Should Be Equal As Strings  ${resp.status_code}  422
        Should Be Equal As Strings  "${resp.json()}"   "${CANNOT_CREATE_APPT_BILL}"


        ${reason}=  Random Element  ${cancelReason}
        ${cancel_msg}=   FakerLibrary.word
        ${resp}=    Provider Cancel Appointment  ${apptid1}  ${reason}  ${cancel_msg}  ${DAY1}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        sleep  02s

        ${resp}=  Get Appointment By Id   ${apptid1}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  uid=${apptid1}  appointmentEncId=${encId1}  appmtDate=${DAY1}  appmtTime=${slot1}  apptBy=PROVIDER   paymentStatus=${paymentStatus[0]}  appointmentMode=${appointmentMode[0]}  apptStatus=${apptStatus[4]}

        ${resp}=  Get Appointment By Id   ${apptid2}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  uid=${apptid2}  appointmentEncId=${encId2}  appmtDate=${DAY1}  appmtTime=${slot2}  apptBy=PROVIDER   paymentStatus=${paymentStatus[0]}  appointmentMode=${appointmentMode[0]}  apptStatus=${apptStatus[1]}

        ${resp}=  Get Appointment By Id   ${apptid3}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  uid=${apptid3}  appointmentEncId=${encId3}  appmtDate=${DAY1}  appmtTime=${slot3}  apptBy=PROVIDER   paymentStatus=${paymentStatus[0]}  appointmentMode=${appointmentMode[0]}  apptStatus=${apptStatus[1]}

        ${resp}=  Get Appointment By Id   ${apptid4}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  uid=${apptid4}  appointmentEncId=${encId4}  appmtDate=${DAY1}  appmtTime=${slot4}  apptBy=PROVIDER   paymentStatus=${paymentStatus[0]}  appointmentMode=${appointmentMode[0]}  apptStatus=${apptStatus[1]}

        ${resp}=  Get Bill By UUId  ${apptid1}
        Should Be Equal As Strings  ${resp.status_code}  422
        Should Be Equal As Strings  "${resp.json()}"   "${CANCELLED_APPT}"

        ${netRate}=   Evaluate   ${service_charge}*3

        ${resp}=  Get Bill By UUId  ${apptid2}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()['uuid']}         ${apptid2}
        Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}         ${netRate}
        Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}         3.0


JD-TC-Get Bill By UUId -4

        [Documentation]   consumer takes appointment for self and family members, 
        ...    Get Bill, makes payment, cancel consumer appointment, Get bill and check bill parent id
        ...    cancel appointment of next family member and get bill 

        # ${resp}=  Consumer Login  ${CUSERNAME9}  ${PASSWORD}
        # Log   ${resp.json()}
        # Should Be Equal As Strings    ${resp.status_code}    200
        # Set Test Variable  ${jdconID}   ${resp.json()['id']}
        # Set Test Variable  ${Con_firstName}   ${resp.json()['firstName']}
        # Set Test Variable  ${Con_lastName}   ${resp.json()['lastName']}

        # ${resp}=  Consumer Logout
        # Log   ${resp.json()}
        # Should Be Equal As Strings    ${resp.status_code}    200

        ${resp}=  Encrypted Provider Login  ${MUSERNAME${a}}  ${PASSWORD}
        Should Be Equal As Strings    ${resp.status_code}    200

        ${resp}=  Get Consumer By Id  ${CUSERNAME9}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${jdconID}   ${resp.json()['id']}
        Set Test Variable  ${Con_firstName}   ${resp.json()['userProfile']['firstName']}
        Set Test Variable  ${Con_lastName}   ${resp.json()['userProfile']['lastName']}

        clear_service   ${MUSERNAME${a}}
        clear_location  ${MUSERNAME${a}}
        clear_queue      ${MUSERNAME${a}}
        clear_appt_schedule   ${MUSERNAME${a}}
        clear_customer   ${MUSERNAME${a}}

        ${resp}=  Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${boolean[0]}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
    
        ${resp}=  Get jaldeeIntegration Settings
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}

        ${resp}=   Get Appointment Settings
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Run Keyword If  ${resp.json()['enableAppt']}==${bool[0]}   Enable Appointment

        ${lid}=  Create Sample Location
        ${DAY1}=  db.get_date_by_timezone  ${tz}
        ${DAY2}=  db.add_timezone_date  ${tz}  10        
        ${list}=  Create List  1  2  3  4  5  6  7
        ${sTime1}=  add_timezone_time  ${tz}  0  15  
        ${delta}=  FakerLibrary.Random Int  min=10  max=60
        ${eTime1}=  add_two   ${sTime1}  ${delta}
        ${s_name}=  FakerLibrary.name
        ${s_id}=  Create Sample Service  ${s_name}
        ${schedule_name}=  FakerLibrary.bs
        ${parallel}=  FakerLibrary.Random Int  min=1  max=10
        ${maxval}=  Convert To Integer   ${delta/4}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
        ${bool1}=  Random Element  ${bool}
        ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}  
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${sch_id}  ${resp.json()}

        # ${resp}=  Create Sample Schedule
        # Set Test Variable  ${sch_id}   ${resp['schedule_id']}
        # Set Test Variable  ${s_id}   ${resp['service_id']}
        # Set Test Variable  ${lid}   ${resp['location_id']}
        # Set Test Variable  ${s_name}   ${resp['service_name']}

        ${resp}=  Get Appointment Schedule ById  ${sch_id}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  id=${sch_id}  apptState=${Qstate[0]}

        ${resp}=  AddCustomer  ${CUSERNAME9}   firstName=${Con_firstName}   lastName=${Con_lastName}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${cid}  ${resp.json()}   
        FOR  ${i}  IN RANGE  1   4
        
                ${firstname}=  FakerLibrary.first_name
                Set Test Variable  ${firstname${i}}  ${firstname}
                ${lastname}=  FakerLibrary.last_name
                Set Test Variable  ${lastname${i}}  ${lastname}
                ${dob}=  FakerLibrary.Date
                Set Test Variable  ${dob${i}}  ${dob}
                ${gender}=   Random Element    ${Genderlist}
                Set Test Variable  ${gender${i}}  ${gender}
                ${resp}=  AddFamilyMemberByProvider   ${cid}  ${firstname${i}}  ${lastname${i}}  ${dob${i}}  ${gender${i}}
                Log  ${resp.json()}
                Should Be Equal As Strings  ${resp.status_code}  200
                Set Test Variable  ${mem_id${i}}  ${resp.json()}
        
        END

        ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  scheduleId=${sch_id}
        Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
        Set Test Variable   ${slot2}   ${resp.json()['availableSlots'][1]['time']}
        Set Test Variable   ${slot3}   ${resp.json()['availableSlots'][2]['time']}
        Set Test Variable   ${slot4}   ${resp.json()['availableSlots'][3]['time']}

        ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
        ${apptfor2}=  Create Dictionary  id=${mem_id1}   apptTime=${slot2}
        ${apptfor3}=  Create Dictionary  id=${mem_id2}   apptTime=${slot3}
        ${apptfor4}=  Create Dictionary  id=${mem_id3}   apptTime=${slot4}
        ${apptfor}=   Create List  ${apptfor1}  ${apptfor2}  ${apptfor3}  ${apptfor4}

        ${cnote}=   FakerLibrary.word
        ${resp}=  Take Appointment For Consumer   ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${Keys}=  Get Dictionary Keys  ${resp.json()}   sort_keys=False 
        ${apptid1}=  Get From Dictionary  ${resp.json()}  ${Con_firstName}
        ${apptid2}=  Get From Dictionary  ${resp.json()}  ${firstName1}
        ${apptid3}=  Get From Dictionary  ${resp.json()}  ${firstName2}
        ${apptid4}=  Get From Dictionary  ${resp.json()}  ${firstName3}

        FOR  ${i}  IN RANGE  1   5

                ${resp}=  Get Appointment EncodedID   ${apptid${i}}
                Log   ${resp.json()}
                Should Be Equal As Strings  ${resp.status_code}  200
                ${encId}=   Set Variable   ${resp.json()}
                Set Test Variable  ${encId${i}}  ${encId}

        END

        ${resp}=  Get Appointment By Id   ${apptid1}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  uid=${apptid1}  appointmentEncId=${encId1}  appmtDate=${DAY1}  appmtTime=${slot1}  apptBy=PROVIDER   paymentStatus=${paymentStatus[0]}  appointmentMode=${appointmentMode[0]}  apptStatus=${apptStatus[1]}

        ${resp}=  Get Appointment By Id   ${apptid2}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  uid=${apptid2}  appointmentEncId=${encId2}  appmtDate=${DAY1}  appmtTime=${slot2}  apptBy=PROVIDER   paymentStatus=${paymentStatus[0]}  appointmentMode=${appointmentMode[0]}  apptStatus=${apptStatus[1]}

        ${resp}=  Get Appointment By Id   ${apptid3}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  uid=${apptid3}  appointmentEncId=${encId3}  appmtDate=${DAY1}  appmtTime=${slot3}  apptBy=PROVIDER   paymentStatus=${paymentStatus[0]}  appointmentMode=${appointmentMode[0]}  apptStatus=${apptStatus[1]}

        ${resp}=  Get Appointment By Id   ${apptid4}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  uid=${apptid4}  appointmentEncId=${encId4}  appmtDate=${DAY1}  appmtTime=${slot4}  apptBy=PROVIDER   paymentStatus=${paymentStatus[0]}  appointmentMode=${appointmentMode[0]}  apptStatus=${apptStatus[1]}

        ${resp}=   Get Service
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()[0]['id']}   ${s_id}
        Set Test Variable   ${service_charge}   ${resp.json()[0]['totalAmount']}

        ${netRate}=   Evaluate   ${service_charge}*4
        
        ${resp}=  Get Bill By UUId  ${apptid1}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()['uuid']}         ${apptid1}
        Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}         ${netRate}
        Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}         4.0

        ${resp}=  Get Bill By UUId  ${apptid2}
        Log   ${resp.json()}
        # Should Be Equal As Strings  ${resp.status_code}  422
        # Should Be Equal As Strings  "${resp.json()}"   "${CANNOT_CREATE_BILL}"

        ${resp}=  Get Bill By UUId  ${apptid3}
        Log   ${resp.json()}

        ${resp}=  Get Bill By UUId  ${apptid4}
        Log   ${resp.json()}

        ${resp}=  Accept Payment  ${apptid1}  ${acceptPaymentBy[0]}  ${netRate}  
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=  Get Bill By UUId  ${apptid1}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=  Settl Bill  ${apptid1}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=  Get Bill By UUId  ${apptid1}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()['uuid']}  ${apptid1}    
        Should Be Equal As Strings  ${resp.json()['billStatus']}  ${billStatus[1]} 

        ${resp}=  Get Bill By UUId  ${apptid2}
        Log   ${resp.json()}

        ${resp}=  Get Bill By UUId  ${apptid3}
        Log   ${resp.json()}

        ${resp}=  Get Bill By UUId  ${apptid4}
        Log   ${resp.json()}

        ${reason}=  Random Element  ${cancelReason}
        ${cancel_msg}=   FakerLibrary.word
        ${resp}=    Provider Cancel Appointment  ${apptid1}  ${reason}  ${cancel_msg}  ${DAY1}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        sleep  02s

        ${resp}=  Get Appointment By Id   ${apptid1}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  uid=${apptid1}  appointmentEncId=${encId1}  appmtDate=${DAY1}  appmtTime=${slot1}  apptBy=PROVIDER   paymentStatus=${paymentStatus[2]}  appointmentMode=${appointmentMode[0]}  apptStatus=${apptStatus[4]}

        ${resp}=  Get Appointment By Id   ${apptid2}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  uid=${apptid2}  appointmentEncId=${encId2}  appmtDate=${DAY1}  appmtTime=${slot2}  apptBy=PROVIDER   paymentStatus=${paymentStatus[2]}  appointmentMode=${appointmentMode[0]}  apptStatus=${apptStatus[1]}

        ${resp}=  Get Appointment By Id   ${apptid3}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  uid=${apptid3}  appointmentEncId=${encId3}  appmtDate=${DAY1}  appmtTime=${slot3}  apptBy=PROVIDER   paymentStatus=${paymentStatus[2]}  appointmentMode=${appointmentMode[0]}  apptStatus=${apptStatus[1]}

        ${resp}=  Get Appointment By Id   ${apptid4}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  uid=${apptid4}  appointmentEncId=${encId4}  appmtDate=${DAY1}  appmtTime=${slot4}  apptBy=PROVIDER   paymentStatus=${paymentStatus[2]}  appointmentMode=${appointmentMode[0]}  apptStatus=${apptStatus[1]}

        ${resp}=  Get Bill By UUId  ${apptid1}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  422
        Should Be Equal As Strings  "${resp.json()}"   "${CANCELLED_APPT}"

        ${netRate}=   Evaluate   ${service_charge}*3
        ${netrate}=  Convert To Number  ${netrate}  2

        ${resp}=  Get Bill By UUId  ${apptid2}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()['uuid']}         ${apptid2}
        Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}         ${netRate}
        Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}         3.0