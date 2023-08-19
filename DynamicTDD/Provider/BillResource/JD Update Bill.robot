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
Resource          /ebs/TDD/SuperAdminKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py


*** Variables ***

${item1}  ITEM1
${SERVICE1}  SERVICE1
${SERVICE2}  SERVICE2
${SERVICE3}  SERVICE3
${SERVICE4}  SERVICE4
${queue1}   Morning
${item2}  ITEM2
${coupon1}  coupon1
${coupon2}  coupon2
${discount1}  onam discount
${discount2}  xmas discount
@{service_duration}  10  20  30   40   50
${itemCode1}   itemCode1
${itemCode2}   itemCode2
${DisplayName1}   item1_DisplayName
${DisplayName2}   item2_DisplayName


*** Test Cases ***

JD-TC- Update Bill -PRE

    [Documentation]   Update Bill for service
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
    ${PUSERNAME_Z}=  Evaluate  ${PUSERNAME}+31480              
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
    ${resp}=  Provider Login  ${PUSERNAME_Z}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 

    
    #${dis}   ${service_duration[2]}  ${status[0]}  ${btype}   ${bool[1]}   ${notifytype[2]}   0  500  ${bool[0]}  ${bool[1]}
    ${desc}=  FakerLibrary.sentence
    set Suite Variable   ${desc}
    ${ser_durtn}=   Random Int   min=2   max=10
    Set Suite Variable   ${ser_durtn}
    ${ser_amount}=   Random Int   min=1000   max=2000
    ${ser_amount}=   Convert To Number   ${ser_amount}
    Set Suite Variable   ${ser_amount}
    ${resp}=  Create Service  ${SERVICE1}  ${desc}   ${ser_durtn}   ${status[0]}  ${btype}   ${bool[1]}   ${notifytype[2]}  ${EMPTY}  ${ser_amount}  ${bool[0]}  ${bool[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sid1}  ${resp.json()}
    ${ser_durtn}=   Random Int   min=2   max=10
    Set Suite Variable   ${ser_durtn}
    ${ser_amount}=   Random Int   min=1000   max=2000
    ${ser_amount}=   Convert To Number   ${ser_amount}
    Set Suite Variable   ${ser_amount}
    ${resp}=  Create Service  ${SERVICE2}  ${desc}   ${ser_durtn}   ${status[0]}  ${btype}   ${bool[1]}   ${notifytype[2]}  ${EMPTY}  ${ser_amount}  ${bool[0]}  ${bool[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sid2}  ${resp.json()}
    ${ser_durtn}=   Random Int   min=2   max=10
    Set Suite Variable   ${ser_durtn}
    ${ser_amount}=   Random Int   min=1000   max=2000
    ${ser_amount}=   Convert To Number   ${ser_amount}
    Set Suite Variable   ${ser_amount}
    ${resp}=  Create Service  ${SERVICE3}  ${desc}   ${ser_durtn}   ${status[0]}  ${btype}   ${bool[1]}   ${notifytype[2]}  ${EMPTY}  ${ser_amount}  ${bool[0]}  ${bool[0]}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Suite Variable  ${sid3}  ${resp.json()}
    ${ser_durtn}=   Random Int   min=2   max=10
    Set Suite Variable   ${ser_durtn}
    ${ser_amount}=   Random Int   min=1000   max=2000
    ${ser_amount}=   Convert To Number   ${ser_amount}
    Set Suite Variable   ${ser_amount}
    ${resp}=  Create Service  ${SERVICE4}  ${desc}   ${ser_durtn}   ${status[0]}  ${btype}   ${bool[1]}   ${notifytype[2]}  ${EMPTY}  ${ser_amount}  ${bool[0]}  ${bool[0]}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Suite Variable  ${sid4}  ${resp.json()}
    ${DAY}=  get_date
    Set Suite Variable  ${DAY}
    ${list}=  Create List  1  2  3  4  5  6  7
    ${PUSERPH4}=  Evaluate  ${PUSERNAME}+305
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERPH4}${\n}
    ${PUSERPH5}=  Evaluate  ${PUSERNAME}+306
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERPH5}${\n}
    ${PUSERMAIL3}=   Set Variable  ${P_Email}${PUSERPH4}.ynwtest@netvarth.com
    ${views}=  Evaluate  random.choice($Views)  random
    ${name1}=  FakerLibrary.name
    ${name2}=  FakerLibrary.name
    ${name3}=  FakerLibrary.name
    ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${PUSERPH4}  ${views}
    ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${PUSERPH5}  ${views}
    ${emails1}=  Emails  ${name3}  Email  ${PUSERMAIL3}  ${views}
    ${bs}=  FakerLibrary.bs
    ${city}=   get_place
    ${latti}=  get_latitude
    ${longi}=  get_longitude
    ${companySuffix}=  FakerLibrary.companySuffix
    ${postcode}=  FakerLibrary.postcode
    ${address}=  get_address
    ${sTime}=  db.get_time
    ${eTime}=  add_time   0  15
    ${desc}=   FakerLibrary.sentence
    ${url}=   FakerLibrary.url
    ${parking}   Random Element   ${parkingType}
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
    ${sTime}=  add_time  1  30
    ${eTime}=  add_time   3  00
    ${queue1}=   FakerLibrary.word
    ${resp}=  Create Queue  ${queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${parallel}  ${capacity}  ${lid}  ${sid1}  ${sid2}   ${sid3}  ${sid4}
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
    Set Suite Variable  ${bid}  ${resp.json()['id']}
    ${des}=  FakerLibrary.word
    ${service}=  Service Bill  ${des}  ${sid2}  1 
    ${resp}=  Update Bill   ${wid}  addService   ${service}
    Should Be Equal As Strings  ${resp.status_code}  200

    
    # ${resp}=  Create Item   ${item1}   ${des}  ${des}  100  ${bool[1]}
    ${resp}=  Create Sample Item   ${DisplayName1}   ${item1}  ${itemCode1}  100  ${bool[1]}           
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Suite Variable  ${itemId}  ${resp.json()}

    # ${resp}=  Create Item   ${item2}  ${des}  ${des}  100  ${bool[1]} 
    ${resp}=  Create Sample Item   ${DisplayName2}  ${item2}  ${itemCode2}  100  ${bool[1]}          
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${itemId1}  ${resp.json()}

    ${item}=  Item Bill  my Item  ${itemId}  1
    ${resp}=  Update Bill   ${wid}  addItem   ${item}
    Should Be Equal As Strings  ${resp.status_code}  200

    
    # ${resp}=  Create Coupon   ${coupon1}   ${des}   20   ${calctype[1]}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${couponId}  ${resp.json()}

    # ${resp}=  Create Coupon  ${coupon2}  ${des}  20  ${calctype[1]}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${couponId1}  ${resp.json()}

    ${coupon1}=    FakerLibrary.word
    ${desc}=  FakerLibrary.Sentence   nb_words=2
    ${cou_amount}=  FakerLibrary.Pyfloat  positive=True  left_digits=3  right_digits=1
    ${cou_amount}=   Convert To Number   ${cou_amount}
    Set Suite Variable  ${cou_amount}
    ${cupn_code1}=   FakerLibrary.word
    Set Suite Variable  ${cupn_code1}
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime}=  subtract_time  0  15
    ${eTime}=  add_time   0  45
    ${ST_DAY}=  get_date
    ${EN_DAY}=  add_date   10
    ${min_bill_amount}=   Random Int   min=500   max=750
    ${max_disc_val}=   Random Int   min=50   max=100
    ${max_prov_use}=   Random Int   min=10   max=20
    ${book_channel}=   Create List   ${bookingChannel[0]}
    ${coupn_based}=  Create List   ${couponBasedOn[0]}
    ${tc}=  FakerLibrary.sentence
    ${services}=   Create list   ${sid1}   ${sid2}  ${sid3}
    ${items}=   Create List   ${itemId}
    ${resp}=  Create Provider Coupon   ${coupon1}  ${desc}  ${cou_amount}  ${calctype[1]}  ${cupn_code1}  ${recurringtype[1]}  ${list}  ${sTime}  ${eTime}  ${ST_DAY}  ${EN_DAY}  ${EMPTY}  ${bool[0]}  ${min_bill_amount}  ${max_disc_val}  ${bool[1]}  ${max_prov_use}  ${book_channel}  ${coupn_based}  ${tc}  services=${services}  items=${items} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${couponId}  ${resp.json()}
    
    ${coupon2}=    FakerLibrary.word
    ${desc}=  FakerLibrary.Sentence   nb_words=2
    ${cou_amount}=  FakerLibrary.Pyfloat  positive=True  left_digits=3  right_digits=1
    ${cou_amount}=   Convert To Number   ${cou_amount}
    Set Suite Variable  ${cou_amount}
    ${cupn_code2}=   FakerLibrary.word
    Set Suite Variable  ${cupn_code2}
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime}=  subtract_time  0  15
    ${eTime}=  add_time   0  45
    ${ST_DAY}=  get_date
    ${EN_DAY}=  add_date   10
    ${min_bill_amount}=   Random Int   min=500   max=750
    ${max_disc_val}=   Random Int   min=50   max=100
    ${max_prov_use}=   Random Int   min=10   max=20
    ${book_channel}=   Create List   ${bookingChannel[0]}
    ${coupn_based}=  Create List   ${couponBasedOn[0]}
    ${tc}=  FakerLibrary.sentence
    ${services}=   Create list   ${sid1}   ${sid2}  ${sid3}
    ${items}=   Create List   ${itemId}
    ${resp}=  Create Provider Coupon   ${coupon2}  ${desc}  ${cou_amount}  ${calctype[1]}  ${cupn_code2}  ${recurringtype[1]}  ${list}  ${sTime}  ${eTime}  ${ST_DAY}  ${EN_DAY}  ${EMPTY}  ${bool[0]}  ${min_bill_amount}  ${max_disc_val}  ${bool[1]}  ${max_prov_use}  ${book_channel}  ${coupn_based}  ${tc}  services=${services}  items=${items} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${couponId1}  ${resp.json()}
    

    # ${coupon}=  Provider Coupons  ${bid}  ${couponId}
    ${resp}=  Update Bill   ${wid}  addProviderCoupons   ${cupn_code1}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Create Discount  ${discount1}   ${desc}    10  ${calctype[1]}  ${disctype[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${discountId}   ${resp.json()}

    ${resp}=   Create Discount  ${discount2}   ${des}    5  ${calctype[1]}  ${disctype[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${discountId1}   ${resp.json()}

    ${disc1}=  Bill Discount Input  ${discountId}  ${desc}  ${des}
    ${bdisc}=  Bill Discount  ${bid}  ${disc1}   
    ${resp}=  Update Bill   ${wid}  addBillLevelDiscount  ${bdisc}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${item}=  Item Bill  ${desc}  ${itemId}   1  ${discountId}
    ${resp}=  Update Bill   ${wid}  addItemLevelDiscount   ${item}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${service}=  Service Bill  ${desc}  ${sid1}  1  ${discountId}
    ${resp}=  Update Bill   ${wid}  addServiceLevelDiscount   ${service}  
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log   ${resp.json()}

    Set Test Variable  ${due}  ${resp.json()['amountDue']}
    ${resp}=  Accept Payment  ${wid}  cash  ${due}  
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Settl Bill  ${wid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    

JD-TC- Update Bill -UH1    

    [Documentation]    add service to Settled bill

    ${des}=  FakerLibrary.Word
    ${resp}=  ProviderLogin   ${PUSERNAME_Z}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${service}=  Service Bill  ${des}  ${sid4}  1 
    ${resp}=  Update Bill   ${wid}  addService   ${service}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${YOU_CAN_NOT_UPDATE_BILL}"


JD-TC- Update Bill -UH2

    [Documentation]  add item to Settled bill

    ${des}=  FakerLibrary.Word
    ${resp}=  ProviderLogin   ${PUSERNAME_Z}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${item}=  Item Bill  ${des}  ${itemId1}  1
    ${resp}=  Update Bill   ${wid}  addItem   ${item}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${YOU_CAN_NOT_UPDATE_BILL}"


JD-TC- Update Bill -UH3

    [Documentation]  add coupon to Settled bill

    ${resp}=  ProviderLogin   ${PUSERNAME_Z}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    # ${coupon}=  Provider Coupons  ${bid}  ${couponId1}
    ${resp}=  Update Bill   ${wid}  addProviderCoupons   ${cupn_code1}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${YOU_CAN_NOT_UPDATE_BILL}"

JD-TC- Update Bill -UH4

    [Documentation]   add discount to Settled bill

    ${des}=  FakerLibrary.Word
    ${resp}=  ProviderLogin   ${PUSERNAME_Z}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${disc1}=  Bill Discount Input  ${discountId1}  ${des}  ${des}
    ${bdisc}=  Bill Discount  ${bid}  ${disc1}   

    ${resp}=  Update Bill   ${wid}  addBillLevelDiscount  ${bdisc}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${YOU_CAN_NOT_UPDATE_BILL}"

JD-TC- Update Bill -UH5

    [Documentation]  add service level discount to Settled bill

    ${des}=  FakerLibrary.Word
    ${resp}=  ProviderLogin   ${PUSERNAME_Z}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${service}=  Service Bill  ${des}  ${sid1}  1  ${discountId1}
    ${resp}=  Update Bill   ${wid}  addServiceLevelDiscount   ${service} 
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${YOU_CAN_NOT_UPDATE_BILL}"

JD-TC- Update Bill -UH6

    [Documentation]   add item level discount to Settled bill

    ${des}=  FakerLibrary.Word
    ${resp}=  ProviderLogin   ${PUSERNAME_Z}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${item}=  Item Bill  ${des}  ${itemId}   1  ${discountId1}
    ${resp}=  Update Bill   ${wid}  addItemLevelDiscount   ${item}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${YOU_CAN_NOT_UPDATE_BILL}"


JD-TC- Update Bill -UH7

    [Documentation]  remove service from Settled bill

    ${des}=  FakerLibrary.Word
    ${resp}=  ProviderLogin   ${PUSERNAME_Z}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${service}=  Service Bill  ${des}  ${s_id1}  1 
    ${resp}=  Update Bill   ${wid}  removeService   ${service}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${YOU_CAN_NOT_UPDATE_BILL}"

JD-TC- Update Bill -UH8

    [Documentation]  remove item from Settled bill

    ${des}=  FakerLibrary.Word
    ${resp}=  ProviderLogin   ${PUSERNAME_Z}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${item}=  Item Bill   ${des}   ${itemId}  1
    ${resp}=  Update Bill   ${wid}  removeItem   ${item}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${YOU_CAN_NOT_UPDATE_BILL}"

JD-TC- Update Bill -UH9

    [Documentation]  remove coupon from Settled bill

    ${resp}=  ProviderLogin   ${PUSERNAME_Z}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    # ${coupon}=  Provider Coupons  ${bid}  ${couponId}
    ${resp}=  Update Bill   ${wid}  removeProviderCoupons   ${cupn_code1}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${YOU_CAN_NOT_UPDATE_BILL}"
JD-TC- Update Bill -UH10

    [Documentation]  remove discount from Settled bill

    ${resp}=  ProviderLogin   ${PUSERNAME_Z}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${bdisc}=  Remove Bill Discount  ${bid}  ${discountId} 
    ${resp}=  Update Bill   ${wid}  removeBillLevelDiscount  ${bdisc}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${YOU_CAN_NOT_UPDATE_BILL}"

JD-TC- Update Bill -UH11

    [Documentation]   remove item level discount from Settled bill

    ${resp}=  ProviderLogin   ${PUSERNAME_Z}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${item}=  Item Bill  my Item  ${itemId}   1  ${discountId}
    ${resp}=  Update Bill   ${wid}  removeItemLevelDiscount   ${item}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${YOU_CAN_NOT_UPDATE_BILL}"

JD-TC- Update Bill -UH12

    [Documentation]  remove service level discount from Settled bill

    ${des}=  FakerLibrary.Word
    ${resp}=  ProviderLogin   ${PUSERNAME_Z}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${service}=  Service Bill  ${des}  ${sid1}  1  ${discountId}
    ${resp}=  Update Bill   ${wid}  removeServiceLevelDiscount   ${service}  
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${YOU_CAN_NOT_UPDATE_BILL}"

JD-TC- Update Bill -UH13

    [Documentation]    Add disabled service to bill
    ${des}=  FakerLibrary.Word
    ${resp}=  ProviderLogin   ${PUSERNAME_Z}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Add To Waitlist  ${cid}  ${sid2}  ${qid1}  ${DAY}  hi  ${bool[1]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${bid}  ${resp.json()['id']}
    ${item}=  Item Bill  ${des}  ${itemId}  1
    ${resp}=  Update Bill   ${wid}  addItem   ${item}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Disable service  ${sid3}  
    Should Be Equal As Strings  ${resp.status_code}  200
    ${service}=  Service Bill  service forme  ${sid3}  1 
    ${resp}=  Update Bill   ${wid}  addService   ${service}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${INACTIVE_SERVICE}"

    ${resp}=  Get Bill By UUId  ${wid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC- Update Bill -UH14

    [Documentation]  Add disabled item to bill
    ${des}=  FakerLibrary.Word
    ${resp}=  ProviderLogin   ${PUSERNAME_Z}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Disable Item  ${itemId1}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Item By Id  ${itemId1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['status']}  ${status[1]}
    ${item}=  Item Bill  ${des}  ${itemId1}  1
    ${resp}=  Update Bill   ${wid}  addItem   ${item}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${INACTIVE_ITEM}"

JD-TC- Update Bill -UH15

    [Documentation]   Add disabled coupon to bill

    ${resp}=  ProviderLogin   ${PUSERNAME_Z}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Disable Coupon  ${couponId}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Coupon By Id  ${couponId} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    # ${coupon}=  Provider Coupons  ${bid}  ${couponId1}
    ${resp}=  Update Bill   ${wid}  addProviderCoupons   ${cupn_code1}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${PROVIDER_COUPON_INACTIVE}"

JD-TC- Update Bill -UH16

    [Documentation]   Add disabled discount to bill

    ${resp}=  ProviderLogin   ${PUSERNAME_Z}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=   Disable Discount  ${discountId1}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${disc1}=  Bill Discount Input  ${discountId1}  pnote  cnote
    ${bdisc}=  Bill Discount  ${bid}  ${disc1}   
    ${resp}=  Update Bill   ${wid}  addBillLevelDiscount  ${bdisc}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${DISCOUNT_DISABLED}"

JD-TC- Update Bill -UH17

    [Documentation]  Add disabled discount to item
    ${des}=  FakerLibrary.Word
    ${resp}=  ProviderLogin   ${PUSERNAME_Z}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
     ${item}=  Item Bill  ${des}  ${itemId}   1  ${discountId1}
    ${resp}=  Update Bill   ${wid}  addItemLevelDiscount   ${item}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${DISCOUNT_DISABLED}"

YNW-TC- Update Bill -UH18

    [Documentation]   Add disabled discount to service
    ${des}=  FakerLibrary.Word
    ${resp}=  ProviderLogin   ${PUSERNAME_Z}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${service}=  Service Bill  ${des}  ${sid1}  1  ${discountId1}
    ${resp}=  Update Bill   ${wid}  addServiceLevelDiscount   ${service} 
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${DISCOUNT_DISABLED}"


