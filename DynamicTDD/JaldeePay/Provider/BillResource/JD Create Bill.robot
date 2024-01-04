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
Variables         /ebs/TDD/varfiles/musers.py

*** Variables ***
${SERVICE1}   CONSULTATION1
${SERVICE2}   CONSULTATION2
${SERVICE3}   CONSULTATION3
${SERVICE4}   CONSULTATION4
${SERVICE5}   CONSULTATION5
${SERVICE6}   CONSULTATION6
${SERVICE8}   CONSULTATION8
${SERVICE9}   CONSULTATION9
${queue1}       Morning
${queue2}       Evening
${queue3}       Afternoon
${item1}   item46
${item2}  item47
${item3}  item50
${item4}  item51

${itemCode1}   itemCode1
${itemCode2}   itemCode2
${itemCode3}   itemCode3
${itemCode4}   itemCode4

${DisplayName1}   item1_DisplayName
${DisplayName2}   item2_DisplayName
${DisplayName3}   item3_DisplayName
${DisplayName4}   item4_DisplayName

${discount1}   Discount1
${discount2}  discount2
${discount3}  discount3
${discount4}  discount4
${coupon1}   COUPON1
${self}     0
${cnote}    hi


*** Test Cases ***

JD-TC-Create Bill -1
        [Documentation]  Create Bill for service
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
        ${PUSERNAME_Z}=  Evaluate  ${PUSERNAME}+31490             
        Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERNAME_Z}${\n}
        ${pkg_id}=   get_highest_license_pkg
        ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${domain}  ${subdomain}  ${PUSERNAME_Z}   ${pkg_id[0]}
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200
        ${resp}=  Account Activation  ${PUSERNAME_Z}  0
        
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
        ${ser_amount}=   Random Int   min=100   max=1000
        ${ser_amount1}=   Convert To Number   ${ser_amount}
        Set Suite Variable   ${ser_amount1}
        ${resp}=  Create Service  ${SERVICE1}  ${desc}   ${ser_durtn}   ${status[0]}  ${btype}   ${bool[1]}   ${notifytype[2]}  ${EMPTY}  ${ser_amount1}  ${bool[0]}  ${bool[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${sid1}  ${resp.json()}
        ${ser_durtn}=   Random Int   min=2   max=10
        ${ser_amount}=   Random Int   min=100   max=1000
        ${ser_amount2}=   Convert To Number   ${ser_amount}
        Set Suite Variable   ${ser_amount2}
        ${resp}=  Create Service  ${SERVICE2}  ${desc}   ${ser_durtn}   ${status[0]}  ${btype}   ${bool[1]}   ${notifytype[2]}  ${EMPTY}  ${ser_amount2}  ${bool[0]}  ${bool[1]}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${sid2}  ${resp.json()}
        ${ser_durtn}=   Random Int   min=2   max=10
        ${ser_amount}=   Random Int   min=100   max=1000
        ${ser_amount3}=   Convert To Number   ${ser_amount}
        Set Suite Variable   ${ser_amount3}
        ${resp}=  Create Service  ${SERVICE3}  ${desc}   ${ser_durtn}   ${status[0]}  ${btype}   ${bool[1]}   ${notifytype[2]}  ${EMPTY}  ${ser_amount3}  ${bool[0]}  ${bool[1]}
        Should Be Equal As Strings  ${resp.status_code}  200  
        Set Suite Variable  ${sid3}  ${resp.json()}
        ${ser_durtn}=   Random Int   min=2   max=10
        ${ser_amount}=   Random Int   min=100   max=1000
        ${ser_amount4}=   Convert To Number   ${ser_amount}
        Set Suite Variable   ${ser_amount4}
        ${resp}=  Create Service  ${SERVICE4}  ${desc}   ${ser_durtn}   ${status[0]}  ${btype}   ${bool[1]}   ${notifytype[2]}  ${EMPTY}  ${ser_amount4}  ${bool[0]}  ${bool[0]}
        Should Be Equal As Strings  ${resp.status_code}  200  
        Set Suite Variable  ${sid4}  ${resp.json()}
        ${ser_amount}=   Random Int   min=100   max=1000
        ${ser_amount5}=   Convert To Number   ${ser_amount}
        Set Suite Variable   ${ser_amount5}
        ${resp}=  Create Service  ${SERVICE5}  ${desc}   ${ser_durtn}   ${status[0]}  ${btype}   ${bool[1]}   ${notifytype[2]}  ${EMPTY}  ${ser_amount5}  ${bool[0]}  ${bool[0]}
        Should Be Equal As Strings  ${resp.status_code}  200  
        Set Suite Variable  ${sid5}  ${resp.json()}
        ${ser_amount}=   Random Int   min=100   max=1000
        ${ser_amount6}=   Convert To Number   ${ser_amount}
        Set Suite Variable   ${ser_amount6}
        ${resp}=  Create Service  ${SERVICE6}  ${desc}   ${ser_durtn}   ${status[0]}  ${btype}   ${bool[1]}   ${notifytype[2]}  ${EMPTY}  ${ser_amount6}  ${bool[0]}  ${bool[0]}
        Should Be Equal As Strings  ${resp.status_code}  200  
        Set Suite Variable  ${sid6}  ${resp.json()}
        
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
        # ${sTime}=  db.get_time_by_timezone   ${tz}
        ${sTime}=  db.get_time_by_timezone  ${tz}
        ${eTime}=  add_timezone_time  ${tz}  4  15  
        ${desc}=   FakerLibrary.sentence  nb_words=2  variable_nb_words=False
        ${url}=   FakerLibrary.url
        ${parking}   Random Element   ${parkingType}

        ${DAY}=  db.get_date_by_timezone  ${tz}
        Set Suite Variable  ${DAY}
        
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
        Set Suite Variable  ${gstper}
        ${resp}=  Update Tax Percentage  ${gstper}  ${GST_num}
        Should Be Equal As Strings    ${resp.status_code}   200

        ${resp}=  Get Tax Percentage
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200  
        
        ${resp}=  Enable Tax
        Should Be Equal As Strings    ${resp.status_code}   200

        ${capacity}=   Random Int   min=20   max=100
        ${parallel}=   Random Int   min=1   max=2
        ${queue1}=   FakerLibrary.word
        ${resp}=  Create Queue  ${queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${parallel}  ${capacity}  ${lid}  ${sid1}  ${sid2}   ${sid3}  ${sid4}  ${sid5}  ${sid6}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${qid1}  ${resp.json()}
        
        ${resp}=  AddCustomer  ${CUSERNAME9}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${cid}  ${resp.json()}

        ${resp}=  Add To Waitlist  ${cid}  ${sid1}  ${qid1}  ${DAY}  ${cnote}  ${bool[1]}  ${cid}
        
        Should Be Equal As Strings  ${resp.status_code}  200
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Suite Variable  ${wid}  ${wid[0]}
        ${resp}=  Get Bill By UUId  ${wid}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  uuid=${wid}  netTotal=${ser_amount1}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  netRate=${ser_amount1}  billPaymentStatus=${paymentStatus[0]}  totalAmountPaid=0.0  amountDue=${ser_amount1}  taxableTotal=0.0  totalTaxAmount=0.0
        Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${sid1}
        Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE1} 
        Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
        Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}    0.0 
        Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  ${ser_amount1}
        Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}  ${ser_amount1}

       
JD-TC-Create Bill -2

        [Documentation]   add service to bill
        ${resp}=  Encrypted Provider Login  ${PUSERNAME_Z}  ${PASSWORD}
        Should Be Equal As Strings    ${resp.status_code}    200
        ${reason}=   FakerLibrary.word
        ${service}=  Service Bill  ${reason}  ${sid2}  1 
        ${resp}=  Update Bill   ${wid}  ${action[0]}    ${service}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${taxamnt}=  Evaluate  ${ser_amount2}* ${gstper}/100
        ${taxamnt}=  Convert To Number  ${taxamnt}  2
        ${netTotal}=  Evaluate  ${ser_amount1}+${ser_amount2}
        ${netTotal}=  Convert To Number  ${netTotal}  2
        ${netrate}=  Evaluate  ${netTotal}+${taxamnt}
        ${netrate}=  Convert To Number  ${netrate}  2
        # ${netrate}=  Evaluate  round(${netrate}) 

        ${resp}=  Get Bill By UUId  ${wid}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  uuid=${wid}  netTotal=${netTotal}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}   billPaymentStatus=${paymentStatus[0]}  totalAmountPaid=0.0   taxableTotal=${ser_amount2}  totalTaxAmount=${taxamnt}
        
        Should Be Equal As Numbers  ${resp.json()['netRate']}  ${netrate}
        Should Be Equal As Numbers  ${resp.json()['amountDue']}  ${netrate}
        Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${sid1}
        Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE1} 
        Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
        Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}    0.0
        Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  ${ser_amount1}
        Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}  ${ser_amount1}
        Should Be Equal As Strings  ${resp.json()['service'][1]['serviceId']}  ${sid2}
        Should Be Equal As Strings  ${resp.json()['service'][1]['serviceName']}  ${SERVICE2} 
        Should Be Equal As Strings  ${resp.json()['service'][1]['quantity']}  1.0
        Should Be Equal As Strings  ${resp.json()['service'][1]['GSTpercentage']}    ${gstper} 
        Should Be Equal As Strings  ${resp.json()['service'][1]['price']}  ${ser_amount2}
        Should Be Equal As Strings  ${resp.json()['service'][1]['netRate']}  ${ser_amount2}

JD-TC- Create Bill -3

        [Documentation]  remove service from bill
        ${resp}=  Encrypted Provider Login  ${PUSERNAME_Z}  ${PASSWORD}
        Should Be Equal As Strings    ${resp.status_code}    200
        ${reason}=   FakerLibrary.word
        ${service}=  Service Bill  ${reason}  ${sid1}  1 
        ${resp}=  Update Bill   ${wid}  ${action[2]}    ${service}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.status_code}  200
        ${taxamnt}=  Evaluate  ${ser_amount2}* ${gstper}/100
        ${taxamnt}=  Convert To Number  ${taxamnt}  2
        ${netrate}=  Evaluate  ${ser_amount2}+${taxamnt}
        ${netrate}=  Convert To Number  ${netrate}  2
        # ${netrate}=  Evaluate  round(${netrate}) 

        ${resp}=  Get Bill By UUId  ${wid}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  uuid=${wid}  netTotal=${ser_amount2}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}   billPaymentStatus=${paymentStatus[0]}  totalAmountPaid=0.0   taxableTotal=${ser_amount2}  totalTaxAmount=${taxamnt}
        
        Should Be Equal As Numbers  ${resp.json()['netRate']}  ${netrate}
        Should Be Equal As Numbers  ${resp.json()['amountDue']}  ${netrate}
        Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${sid2}
        Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE2} 
        Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
        Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}    ${gstper} 
        Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  ${ser_amount2}
        Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}  ${ser_amount2}

JD-TC- Create Bill -4

        [Documentation]   remove all services from bill
        ${resp}=  Encrypted Provider Login  ${PUSERNAME_Z}  ${PASSWORD}
        Should Be Equal As Strings    ${resp.status_code}    200
        ${reason}=   FakerLibrary.word
        ${service}=  Service Bill  ${reason}  ${sid2}  1 
        ${resp}=  Update Bill   ${wid}  ${action[2]}    ${service}
        Should Be Equal As Strings  ${resp.status_code}  200

JD-TC- Create Bill -5

        [Documentation]  adjust service 
        ${resp}=  Encrypted Provider Login  ${PUSERNAME_Z}  ${PASSWORD}
        Should Be Equal As Strings    ${resp.status_code}    200
        ${reason}=   FakerLibrary.word
        ${service}=  Service Bill  ${reason}  ${sid2}  3 
        ${resp}=  Update Bill   ${wid}  ${action[1]}    ${service}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${taxamnt}=  Evaluate  3*${ser_amount2}* ${gstper}/100
        ${taxamnt}=  Convert To Number  ${taxamnt}  2
        ${netTotal}=  Evaluate  3*${ser_amount2}
        ${netTotal}=  Convert To Number  ${netTotal}  2
        ${netrate}=  Evaluate  ${netTotal}+${taxamnt}
        ${netrate}=  Convert To Number  ${netrate}  2
        # ${netrate}=  Evaluate  round(${netrate}) 

        ${resp}=  Get Bill By UUId  ${wid}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  uuid=${wid}  netTotal=${netTotal}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}   billPaymentStatus=${paymentStatus[0]}  totalAmountPaid=0.0   taxableTotal=${netTotal}  totalTaxAmount=${taxamnt}
        
        Should Be Equal As Numbers  ${resp.json()['netRate']}  ${netrate}
        Should Be Equal As Numbers  ${resp.json()['amountDue']}  ${netrate}
        Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${sid2}
        Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE2} 
        Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  3.0
        Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}    ${gstper} 
        Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  ${ser_amount2}
        Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}  ${netTotal}     



JD-TC- Create Bill -6

        [Documentation]   Add item to bill
        ${resp}=  Encrypted Provider Login  ${PUSERNAME_Z}  ${PASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${des}=  FakerLibrary.Word
        ${description}=  FakerLibrary.sentence  nb_words=2  variable_nb_words=False
        ${it_amount}=   Random Int   min=100   max=1000
        ${it_amount}=   Convert To Number   ${it_amount}
        Set Suite Variable  ${it_amount}

        ${resp}=  Create Sample Item   ${DisplayName1}   ${item1}  ${itemCode1}  ${it_amount}  ${bool[1]} 
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${itemId}  ${resp.json()}

        # ${resp}=  Create Item   ${item1}   ${des}  ${des}  ${it_amount}  ${bool[1]}  
        # Should Be Equal As Strings  ${resp.status_code}  200
        
        # Set Suite Variable  ${itemId}  ${resp.json()}
        # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME9}
        # Should Be Equal As Strings  ${resp.status_code}  200
        # Set Suite Variable  ${cid}  ${resp.json()[0]['id']}
        ${resp}=  Add To Waitlist  ${cid}  ${sid2}  ${qid1}  ${DAY}  ${cnote}  ${bool[1]}  ${cid}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Suite Variable  ${wid}  ${wid[0]}
        ${resp}=  Get Bill By UUId  ${wid}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${item}=  Item Bill  my Item  ${itemId}  1
        ${resp}=  Update Bill   ${wid}  ${action[3]}    ${item}
        Should Be Equal As Strings  ${resp.status_code}  200
        
        ${netTotal}=  Evaluate  ${ser_amount2}+${it_amount}
        ${netTotal}=  Convert To Number  ${netTotal}  2
        ${taxamnt}=  Evaluate  ${netTotal}* ${gstper}/100
        ${taxamnt}=  Convert To Number  ${taxamnt}  2
        ${netrate}=  Evaluate  ${netTotal}+${taxamnt}
        ${netrate}=  Convert To Number  ${netrate}  2
        # ${netrate}=  Evaluate  round(${netrate}) 
    
        ${resp}=  Get Bill By UUId  ${wid}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  uuid=${wid}  netTotal=${netTotal}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  billPaymentStatus=${paymentStatus[0]}  totalAmountPaid=0.0   taxableTotal=${netTotal}  totalTaxAmount=${taxamnt}
        
        Should Be Equal As Numbers  ${resp.json()['netRate']}  ${netrate}
        Should Be Equal As Numbers  ${resp.json()['amountDue']}  ${netrate}
        Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${sid2}
        Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE2} 
        Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
        Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}    ${gstper} 
        Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  ${ser_amount2}
        Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}  ${ser_amount2}
        Should Be Equal As Strings  ${resp.json()['items'][0]['itemId']}  ${itemId}  
        Should Be Equal As Strings  ${resp.json()['items'][0]['price']}  ${it_amount}
        Should Be Equal As Strings  ${resp.json()['items'][0]['itemName']}  ${DisplayName1} 
        Should Be Equal As Strings  ${resp.json()['items'][0]['quantity']}  1.0
        Should Be Equal As Strings  ${resp.json()['items'][0]['GSTpercentage']}    ${gstper} 


JD-TC- Create Bill -7

        [Documentation]   remove item from bill

        ${resp}=  Encrypted Provider Login  ${PUSERNAME_Z}  ${PASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${item}=  Item Bill  my Item  ${itemId}  1
        ${resp}=  Update Bill   ${wid}  removeItem   ${item}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${taxamnt}=  Evaluate  ${ser_amount2}* ${gstper}/100
        ${taxamnt}=  Convert To Number  ${taxamnt}  2
        ${netrate}=  Evaluate  ${ser_amount2}+${taxamnt}
        ${netrate}=  Convert To Number  ${netrate}  2
        # ${netrate}=  Evaluate  round(${netrate}) 
    
        ${resp}=  Get Bill By UUId  ${wid}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  uuid=${wid}  netTotal=${ser_amount2}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}   billPaymentStatus=${paymentStatus[0]}  totalAmountPaid=0.0   taxableTotal=${ser_amount2}  totalTaxAmount=${taxamnt}
        
        Should Be Equal As Numbers  ${resp.json()['netRate']}  ${netrate}
        Should Be Equal As Numbers  ${resp.json()['amountDue']}  ${netrate}
        Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${sid2}
        Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE2} 
        Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
        Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}    ${gstper} 
        Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  ${ser_amount2}
        Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}  ${ser_amount2}
        Should Not Contain  ${resp.json()}  itemId

JD-TC- Create Bill -8

        [Documentation]  adjust item
        ${resp}=  Encrypted Provider Login  ${PUSERNAME_Z}  ${PASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${item}=  Item Bill  my Item  ${itemId}  2
        ${resp}=  Update Bill   ${wid}  ${action[4]}    ${item}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${netTotal}=  Evaluate  ${ser_amount2}+(2*${it_amount})
        ${netTotal}=  Convert To Number  ${netTotal}  2
        ${taxamnt}=  Evaluate  ${netTotal}* ${gstper}/100
        ${taxamnt}=  Convert To Number  ${taxamnt}  2
        ${netrate}=  Evaluate  ${netTotal}+${taxamnt}
        ${netrate}=  Convert To Number  ${netrate}  2
        # ${netrate}=  Evaluate  round(${netrate}) 
    
        ${resp}=  Get Bill By UUId  ${wid}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        Verify Response  ${resp}  uuid=${wid}  netTotal=${netTotal}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}   billPaymentStatus=${paymentStatus[0]}  totalAmountPaid=0.0   taxableTotal=${netTotal}  totalTaxAmount=${taxamnt}
        
        Should Be Equal As Numbers  ${resp.json()['netRate']}  ${netrate}
        Should Be Equal As Numbers  ${resp.json()['amountDue']}  ${netrate}
        Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${sid2}
        Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE2} 
        Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
        Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}    ${gstper} 
        Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  ${ser_amount2}
        Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}  ${ser_amount2}
        Should Be Equal As Strings  ${resp.json()['items'][0]['itemId']}  ${itemId}  
        Should Be Equal As Strings  ${resp.json()['items'][0]['price']}  ${it_amount}
        Should Be Equal As Strings  ${resp.json()['items'][0]['itemName']}  ${DisplayName1} 
        Should Be Equal As Strings  ${resp.json()['items'][0]['quantity']}  2.0
        Should Be Equal As Strings  ${resp.json()['items'][0]['GSTpercentage']}    ${gstper} 

JD-TC- Create Bill -9 

        [Documentation]   add coupon to netBill
        ${data}=  FakerLibrary.Word
        ${resp}=  Encrypted Provider Login  ${PUSERNAME_Z}  ${PASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${tamount}=  Evaluate  ${ser_amount1}/2
        ${tamount}=   Convert To Integer   ${tamount}

        # ${cou_amount}=   Random Int   min=1   max=${tamount}
        # ${cou_amount}=   Convert To Number   ${cou_amount}
        # Set Suite Variable  ${cou_amount}
        # ${resp}=  Create Coupon  ${coupon1}  ${desc}  ${cou_amount}  ${calctype[1]}
        # Log   ${resp.json()}
        # Should Be Equal As Strings  ${resp.status_code}  200
        # Set Suite Variable  ${couponId}  ${resp.json()}
        ${resp}=  AddCustomer  ${CUSERNAME7}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${cid}  ${resp.json()}

        ${coupon}=    FakerLibrary.word
        ${desc}=  FakerLibrary.Sentence   nb_words=2
        ${cou_amount}=  Random Int   min=1   max=${tamount}
        ${cou_amount}=   Convert To Number   ${cou_amount}
        Set Suite Variable  ${cou_amount}
        ${cupn_code}=   FakerLibrary.word
        Set Suite Variable  ${cupn_code}
        ${list}=  Create List  1  2  3  4  5  6  7
        ${sTime}=  db.subtract_timezone_time  ${tz}  0  15
        ${eTime}=  add_timezone_time  ${tz}  0  45  
        ${ST_DAY}=  db.get_date_by_timezone  ${tz}
        ${EN_DAY}=  db.add_timezone_date  ${tz}   10
        ${min_bill_amount}=   Random Int   min=10   max=50
        ${max_disc_val}=   Random Int   min=50   max=100
        ${max_prov_use}=   Random Int   min=10   max=20
        ${book_channel}=   Create List   ${bookingChannel[0]}
        ${coupn_based}=  Create List   ${couponBasedOn[0]}
        ${tc}=  FakerLibrary.sentence
        ${services}=   Create list   ${sid1}   ${sid2}  ${sid3}
        ${items}=   Create List   ${itemId}
        ${resp}=  Create Provider Coupon   ${coupon}  ${desc}  ${cou_amount}  ${calctype[1]}  ${cupn_code}  ${recurringtype[1]}  ${list}  ${sTime}  ${eTime}  ${ST_DAY}  ${EN_DAY}  ${EMPTY}  ${bool[0]}  ${min_bill_amount}  ${max_disc_val}  ${bool[1]}  ${max_prov_use}  ${book_channel}  ${coupn_based}  ${tc}   services=${services}  items=${items} 
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${couponId}  ${resp.json()}
        
        ${resp}=  Add To Waitlist  ${cid}  ${sid1}  ${qid1}  ${DAY}  ${cnote}  ${bool[1]}  ${cid}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Suite Variable  ${wid}  ${wid[0]}

        ${resp}=  Get Bill By UUId  ${wid}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${item}=  Item Bill  my Item  ${itemId}   1
        ${resp}=  Update Bill   ${wid}  ${action[3]}    ${item}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=  Get Bill By UUId  ${wid}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${bid}  ${resp.json()['id']}
        # ${coupon1}=  Provider Coupons  ${bid}  ${couponId}
        ${resp}=  Update Bill   ${wid}  ${action[12]}    ${cupn_code}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${netTotal}=  Evaluate  ${ser_amount1}+${it_amount}
        ${netTotal}=  Convert To Number  ${netTotal}  2
        ${taxamnt}=  Evaluate  ${it_amount}* ${gstper}/100
        ${taxamnt}=  Convert To Number  ${taxamnt}  2
        ${netrate}=  Evaluate  ${netTotal}+${taxamnt}-${cou_amount}
        ${netrate}=  Convert To Number  ${netrate}  2
        # ${netrate}=  Evaluate  round(${netrate}) 
    
        ${resp}=  Get Bill By UUId  ${wid}
        Should Be Equal As Strings  ${resp.status_code}  200

        Verify Response  ${resp}  uuid=${wid}  netTotal=${netTotal}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}   billPaymentStatus=${paymentStatus[0]}  totalAmountPaid=0.0   taxableTotal=${it_amount}  totalTaxAmount=${taxamnt}
        
        Should Be Equal As Numbers  ${resp.json()['netRate']}  ${netrate}
        Should Be Equal As Numbers  ${resp.json()['amountDue']}  ${netrate}
        Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${sid1}
        Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE1} 
        Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
        Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}    0.0 
        Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  ${ser_amount1}
        Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}  ${ser_amount1}
        Should Be Equal As Strings  ${resp.json()['items'][0]['itemId']}  ${itemId}  
        Should Be Equal As Strings  ${resp.json()['items'][0]['price']}  ${it_amount} 
        Should Be Equal As Strings  ${resp.json()['items'][0]['itemName']}  ${DisplayName1}
        Should Be Equal As Strings  ${resp.json()['items'][0]['quantity']}  1.0
        Should Be Equal As Strings  ${resp.json()['items'][0]['GSTpercentage']}    ${gstper} 
        Should Be Equal As Strings  ${resp.json()['providerCoupon']['${cupn_code}']['value']}  ${cou_amount}  

JD-TC- Create Bill -UH1

        [Documentation]   add same coupon more than once to a bill

        ${resp}=  Encrypted Provider Login  ${PUSERNAME_Z}  ${PASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=  Get Bill By UUId  ${wid}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${bid}  ${resp.json()['id']}

        # ${coupon}=  Provider Coupons  ${bid}  ${couponId}
        ${resp}=  Update Bill   ${wid}  ${action[12]}    ${cupn_code}
        Should Be Equal As Strings  ${resp.status_code}  422
        Should Be Equal As Strings  "${resp.json()}"   "${COUPON_ALREADY_USED}"

JD-TC- Create Bill -10
        [Documentation]  remove coupon from net bill
        
        ${resp}=  Encrypted Provider Login  ${PUSERNAME_Z}  ${PASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        
        ${resp}=  Get Bill By UUId  ${wid}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${bid}  ${resp.json()['id']}
        
        # ${coupon}=  Provider Coupons  ${bid}  ${couponId}
        ${resp}=  Update Bill   ${wid}  ${action[13]}    ${cupn_code}
        Should Be Equal As Strings  ${resp.status_code}  200
        
        ${resp}=  Get Bill By UUId  ${wid}
        Should Be Equal As Strings  ${resp.status_code}  200
        
        ${netTotal}=  Evaluate  ${ser_amount1}+${it_amount}
        ${netTotal}=  Convert To Number  ${netTotal}  2
        ${taxamnt}=  Evaluate  ${it_amount}* ${gstper}/100
        ${taxamnt}=  Convert To Number  ${taxamnt}  2
        ${netrate}=  Evaluate  ${netTotal}+${taxamnt}
        ${netrate}=  Convert To Number  ${netrate}  2
        Verify Response  ${resp}  uuid=${wid}  netTotal=${netTotal}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  netRate=${netrate}  billPaymentStatus=${paymentStatus[0]}  totalAmountPaid=0.0  amountDue=${netrate}  taxableTotal=${it_amount}  totalTaxAmount=${taxamnt}
        Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${sid1}
        Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE1} 
        Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
        Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}    0.0 
        Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  ${ser_amount1}
        Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}  ${ser_amount1}
        Should Be Equal As Strings  ${resp.json()['items'][0]['itemId']}  ${itemId}  
        Should Be Equal As Strings  ${resp.json()['items'][0]['price']}  ${it_amount} 
        Should Be Equal As Strings  ${resp.json()['items'][0]['itemName']}  ${DisplayName1}
        Should Be Equal As Strings  ${resp.json()['items'][0]['quantity']}  1.0
        Should Be Equal As Strings  ${resp.json()['items'][0]['GSTpercentage']}    ${gstper} 

JD-TC- Create Bill -11

        [Documentation]   add itemlevel discount
        
        ${description}=  FakerLibrary.Word
        ${des}=  FakerLibrary.sentence  nb_words=2  variable_nb_words=False
        ${resp}=  Encrypted Provider Login  ${PUSERNAME_Z}  ${PASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${it_amount2}=   Random Int   min=100   max=1000
        ${it_amount2}=   Convert To Number   ${it_amount2}
        # ${resp}=  Create Item   ${item2}   ${description}  ${des}  ${it_amount2}  ${bool[1]}  
        
        ${resp}=  Create Sample Item   ${DisplayName2}   ${item2}  ${itemCode2}  ${it_amount2}  ${bool[1]}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${it_amount2}
        Set Suite Variable  ${itemId2}  ${resp.json()}
        ${dis_amount}=   Random Int   min=1   max=50
        ${dis_amount}=   Convert To Number   ${dis_amount}

        ${resp}=   Create Discount  ${discount1}   ${desc}    ${dis_amount}   ${calctype[0]}  ${disctype[0]}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable   ${discountId}   ${resp.json()}
        Set Suite Variable  ${disc_amount}  ${dis_amount}
        # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME7}
        # Should Be Equal As Strings  ${resp.status_code}  200
        # Set Test Variable  ${cid}  ${resp.json()[0]['id']}
        ${resp}=  Add To Waitlist  ${cid}  ${sid2}  ${qid1}  ${DAY}  ${cnote}  ${bool[1]}  ${cid}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Suite Variable  ${wid}  ${wid[0]}
        ${resp}=  Get Bill By UUId  ${wid}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${reason}=   FakerLibrary.sentence  nb_words=2  variable_nb_words=False
        ${item}=  Item Bill  ${reason}  ${itemId2}   1
        ${resp}=  Update Bill   ${wid}  ${action[3]}    ${item}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${item}=  Item Bill  my Item  ${itemId2}   1  ${discountId}
        ${resp}=  Update Bill   ${wid}  ${action[8]}    ${item}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp}=  Get Bill By UUId  ${wid}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${it_dis}=  Evaluate  ${it_amount2}*${dis_amount}/100
        ${it_netrate}=  Evaluate  ${it_amount2}-${it_dis}
        ${it_netrate}=  Convert To Number  ${it_netrate}  2
        ${taxtot}=  Evaluate  ${it_netrate}+${ser_amount2}
        ${taxtot}=  Convert To Number  ${taxtot}  2
        ${taxamnt}=  Evaluate  ${taxtot}*${gstper}/100
        ${taxamnt}=  Convert To Number  ${taxamnt}  2
        ${netrate}=  Evaluate  ${ser_amount2}+${it_netrate}+${taxamnt}
        ${netrate}=  Convert To Number  ${netrate}  2
        Verify Response  ${resp}  uuid=${wid}  netTotal=${taxtot}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  netRate=${netrate}  billPaymentStatus=${paymentStatus[0]}  totalAmountPaid=0.0  amountDue=${netrate}  taxableTotal=${taxtot}  totalTaxAmount=${taxamnt}
        Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${sid2}
        Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE2} 
        Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
        Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}    ${gstper} 
        Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  ${ser_amount2}
        Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}  ${ser_amount2}
        Should Be Equal As Strings  ${resp.json()['items'][0]['itemId']}  ${itemId2}  
        Should Be Equal As Strings  ${resp.json()['items'][0]['price']}  ${it_amount2} 
        Should Be Equal As Numbers  ${resp.json()['items'][0]['netRate']}  ${it_netrate}
        Should Be Equal As Strings  ${resp.json()['items'][0]['itemName']}  ${DisplayName2}
        Should Be Equal As Strings  ${resp.json()['items'][0]['quantity']}  1.0
        Should Be Equal As Strings  ${resp.json()['items'][0]['GSTpercentage']}    ${gstper} 
        Should Be Equal As Strings  ${resp.json()['items'][0]['discount'][0]['id']}  ${discountId}  
        Should Be Equal As Strings  ${resp.json()['items'][0]['discount'][0]['discountValue']}  ${it_dis}

JD-TC- Create Bill -UH2

        [Documentation]   add same discount more than once to an item
        
        ${resp}=  Encrypted Provider Login  ${PUSERNAME_Z}  ${PASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${item}=  Item Bill  my Item  ${itemId2}   1  ${discountId}
        ${resp}=  Update Bill   ${wid}  ${action[8]}    ${item}
        Should Be Equal As Strings  ${resp.status_code}  422
        Should Be Equal As Strings  "${resp.json()}"  "${DISCOUNT_ALREADY_USED}"

JD-TC- Create Bill -12

        [Documentation]   remove itemlevel discount
        
        ${resp}=  Encrypted Provider Login  ${PUSERNAME_Z}  ${PASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${item}=  Item Bill  my Item  ${itemId2}   1  ${discountId}
        ${resp}=  Update Bill   ${wid}  ${action[9]}    ${item}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp}=  Get Bill By UUId  ${wid}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${netTotal}=  Evaluate  ${ser_amount2}+${it_amount2}
        ${netTotal}=  Convert To Number  ${netTotal}  2
        ${taxamnt}=  Evaluate  ${netTotal}* ${gstper}/100
        ${taxamnt}=  Convert To Number  ${taxamnt}  2
        ${netrate}=  Evaluate  ${netTotal}+${taxamnt}
        ${netrate}=  Convert To Number  ${netrate}  2
        Verify Response  ${resp}  uuid=${wid}  netTotal=${netTotal}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  netRate=${netrate}  billPaymentStatus=${paymentStatus[0]}  totalAmountPaid=0.0  amountDue=${netrate}  taxableTotal=${netTotal}  totalTaxAmount=${taxamnt}
        Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${sid2}
        Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE2} 
        Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
        Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}    ${gstper} 
        Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  ${ser_amount2}
        Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}  ${ser_amount2}
        Should Be Equal As Strings  ${resp.json()['items'][0]['itemId']}  ${itemId2}  
        Should Be Equal As Strings  ${resp.json()['items'][0]['price']}  ${it_amount2}
        Should Be Equal As Strings  ${resp.json()['items'][0]['itemName']}  ${DisplayName2} 
        Should Be Equal As Strings  ${resp.json()['items'][0]['quantity']}  1.0
        Should Be Equal As Strings  ${resp.json()['items'][0]['GSTpercentage']}    ${gstper} 

JD-TC- Create Bill -13

        [Documentation]   add more itemlevel discounts
        
        ${description}=  FakerLibrary.Word
        ${des}=  FakerLibrary.sentence  nb_words=2  variable_nb_words=False
        ${reason}=   FakerLibrary.sentence  nb_words=2  variable_nb_words=False
        
        ${resp}=  Encrypted Provider Login  ${PUSERNAME_Z}  ${PASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${it_amount}=   Random Int   min=100   max=1000
        ${it_amount}=   Convert To Number   ${it_amount}
        # ${resp}=  Create Item   ${item3}   ${description}  ${des}  ${it_amount}  ${bool[1]}
        ${resp}=  Create Sample Item   ${DisplayName3}   ${item3}  ${itemCode3}  ${it_amount}  ${bool[1]}  
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${itemId}  ${resp.json()}
        ${tamount}=  Evaluate  ${ser_amount3}/2
        ${tamount}=   Convert To Integer   ${tamount}
        # ${maxval}=  Evaluate  ${it_amount}/2
        # ${maxval}=   Convert To Integer  ${maxval}
        ${dis_amount}=   Random Int   min=10   max=100
        ${dis_amount1}=   Convert To Number   ${dis_amount}
        ${resp}=   Create Discount  ${discount2}   ${desc}    ${dis_amount1}   ${calctype[1]}  ${disctype[0]}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable   ${discountId1}   ${resp.json()}
        Set Suite Variable  ${discamount1}  ${dis_amount1}
        ${dis_amount}=   Random Int   min=10   max=100
        ${dis_amount2}=   Convert To Number   ${dis_amount}
        ${resp}=   Create Discount  ${discount3}   ${desc}    ${dis_amount2}   ${calctype[1]}  ${disctype[0]}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${discamount2}  ${dis_amount2}
        Set Suite Variable   ${discountId2}   ${resp.json()}
        # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME6}
        # Should Be Equal As Strings  ${resp.status_code}  200
        # Set Test Variable  ${cid}  ${resp.json()[0]['id']}
        ${resp}=  AddCustomer  ${CUSERNAME6}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${cid}  ${resp.json()}
        ${resp}=  Add To Waitlist  ${cid}  ${sid3}  ${qid1}  ${DAY}  ${cnote}  ${bool[1]}  ${cid}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Test Variable  ${wid}  ${wid[0]}
        ${resp}=  Get Bill By UUId  ${wid}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${item}=  Item Bill  ${reason}  ${itemId}   1
        ${resp}=  Update Bill   ${wid}  ${action[3]}    ${item}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${item}=  Item Bill  ${reason}  ${itemId}   1  ${discountId1}
        ${resp}=  Update Bill   ${wid}  ${action[8]}    ${item}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${item}=  Item Bill  ${reason}  ${itemId}   1  ${discountId2}
        ${resp}=  Update Bill   ${wid}  ${action[8]}    ${item}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp}=  Get Bill By UUId  ${wid}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${it_netrate}=  Evaluate  ${it_amount}-${dis_amount1}-${dis_amount2}
        ${taxtot}=  Evaluate  ${it_netrate}+${ser_amount3}
        ${taxamnt}=  Evaluate  ${taxtot}*${gstper}/100
        ${taxamnt}=  Convert To Number  ${taxamnt}  2
        ${netrate}=  Evaluate  ${taxtot}+${taxamnt}
        ${netrate}=  Convert To Number  ${netrate}  2
        Verify Response  ${resp}  uuid=${wid}  netTotal=${taxtot}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  netRate=${netrate}  billPaymentStatus=${paymentStatus[0]}  totalAmountPaid=0.0  amountDue=${netrate}  taxableTotal=${taxtot}  totalTaxAmount=${taxamnt}
        Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${sid3}
        Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE3} 
        Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
        Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}    ${gstper} 
        Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  ${ser_amount3}
        Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}  ${ser_amount3}
        Should Be Equal As Strings  ${resp.json()['items'][0]['itemId']}  ${itemId}  
        Should Be Equal As Strings  ${resp.json()['items'][0]['price']}  ${it_amount}
        Should Be Equal As Strings  ${resp.json()['items'][0]['netRate']}  ${it_netrate}
        Should Be Equal As Strings  ${resp.json()['items'][0]['itemName']}  ${DisplayName3} 
        Should Be Equal As Strings  ${resp.json()['items'][0]['quantity']}  1.0
        Should Be Equal As Strings  ${resp.json()['items'][0]['GSTpercentage']}    ${gstper} 
        Should Be Equal As Strings  ${resp.json()['items'][0]['discount'][0]['id']}  ${discountId1}  
        Should Be Equal As Strings  ${resp.json()['items'][0]['discount'][0]['discountValue']}  ${dis_amount1}
        Should Be Equal As Strings  ${resp.json()['items'][0]['discount'][1]['id']}  ${discountId2}  
        Should Be Equal As Strings  ${resp.json()['items'][0]['discount'][1]['discountValue']}  ${dis_amount2}


JD-TC- Create Bill -14      
        [Documentation]   add service level discount
        ${reason}=   FakerLibrary.sentence  nb_words=2  variable_nb_words=False
        ${resp}=  Encrypted Provider Login  ${PUSERNAME_Z}  ${PASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME4}
        # Should Be Equal As Strings  ${resp.status_code}  200
        # Set Suite Variable  ${cid}  ${resp.json()[0]['id']}
        ${resp}=  AddCustomer  ${CUSERNAME4}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${cid}  ${resp.json()}
        ${resp}=  Add To Waitlist   ${cid}   ${sid3}   ${qid1}   ${DAY}   ${cnote}   ${bool[1]}   ${cid}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Suite Variable  ${wid}  ${wid[0]}
        ${resp}=  Get Bill By UUId  ${wid}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${item}=  Item Bill  ${reason}  ${itemId}   1
        ${resp}=  Update Bill   ${wid}  ${action[3]}    ${item}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${service}=  Service Bill   ${reason}   ${sid3}  1  ${discountId}
        ${resp}=  Update Bill   ${wid}  ${action[6]}    ${service} 
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp}=  Get Bill By UUId  ${wid} 
        Should Be Equal As Strings  ${resp.status_code}  200
        ${se_dis}=  Evaluate  ${ser_amount3}*${disc_amount}/100
        ${se_netrate}=  Evaluate  ${ser_amount3}-${se_dis}
        ${se_netrate}=  twodigitfloat  ${se_netrate}

        ${taxtot}=  Evaluate  ${se_netrate}+${it_amount}
        ${taxtot}=  Convert To Number  ${taxtot}  2
        ${taxamnt}=  Evaluate  ${taxtot}*${gstper}/100
        ${taxamnt}=  Convert To Number  ${taxamnt}  2
        ${netrate}=  Evaluate  ${it_amount}+${se_netrate}+${taxamnt}
        ${netrate}=  twodigitfloat  ${netrate}

        Verify Response  ${resp}  uuid=${wid}  netTotal=${taxtot}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  
        ...     billPaymentStatus=${paymentStatus[0]}  totalAmountPaid=0.0    taxableTotal=${taxtot}  totalTaxAmount=${taxamnt}
        
        Should Be Equal As Numbers  ${resp.json()['netRate']}   ${netrate} 
        Should Be Equal As Numbers  ${resp.json()['amountDue']}   ${netrate}   
        Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${s_id3}
        Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE3} 
        Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
        Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}    ${gstper} 
        Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  ${ser_amount3}
        Should Be Equal As Numbers  ${resp.json()['service'][0]['netRate']}  ${se_netrate} 
        Should Be Equal As Strings  ${resp.json()['items'][0]['itemId']}  ${itemId}  
        Should Be Equal As Strings  ${resp.json()['items'][0]['price']}  ${it_amount}
        Should Be Equal As Strings  ${resp.json()['items'][0]['itemName']}  ${DisplayName1} 
        Should Be Equal As Strings  ${resp.json()['items'][0]['quantity']}  1.0
        Should Be Equal As Strings  ${resp.json()['items'][0]['GSTpercentage']}    ${gstper} 
        Should Be Equal As Strings  ${resp.json()['service'][0]['discount'][0]['id']}  ${discountId}  
        Should Be Equal As Strings  ${resp.json()['service'][0]['discount'][0]['discountValue']}  ${se_dis}  

JD-TC- Create Bill -UH3
        [Documentation]   add same discount more than once to a service
        ${reason}=   FakerLibrary.sentence  nb_words=2  variable_nb_words=False
        ${resp}=  Encrypted Provider Login  ${PUSERNAME_Z}  ${PASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${service}=  Service Bill  ${reason}   ${sid3}  1  ${discountId}
        ${resp}=  Update Bill   ${wid}  ${action[6]}    ${service}  
        Should Be Equal As Strings  ${resp.status_code}  422
        Should Be Equal As Strings  "${resp.json()}"  "${DISCOUNT_ALREADY_USED}"

JD-TC- Create Bill -15
        [Documentation]  remove service level discount
        ${reason}=   FakerLibrary.sentence  nb_words=2  variable_nb_words=False
        ${resp}=  Encrypted Provider Login  ${PUSERNAME_Z}  ${PASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${service}=  Service Bill  ${reason}  ${sid3}  1  ${discountId}
        ${resp}=  Update Bill   ${wid}  ${action[7]}    ${service}  
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp}=  Get Bill By UUId  ${wid} 
        Should Be Equal As Strings  ${resp.status_code}  200
        ${netTotal}=  Evaluate  ${ser_amount3}+${it_amount}
        ${netTotal}=  Convert To Number  ${netTotal}  2
        ${taxamnt}=  Evaluate  ${netTotal}* ${gstper}/100
        ${taxamnt}=  Convert To Number  ${taxamnt}  2
        ${netrate}=  Evaluate  ${netTotal}+${taxamnt}
        ${netrate}=  Convert To Number  ${netrate}  2
        Verify Response  ${resp}  uuid=${wid}  netTotal=${netTotal}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  netRate=${netrate}  billPaymentStatus=${paymentStatus[0]}  totalAmountPaid=0.0  amountDue=${netrate}  taxableTotal=${netTotal}  totalTaxAmount=${taxamnt}
        Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${s_id3}
        Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE3} 
        Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
        Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}    ${gstper} 
        Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  ${ser_amount3}
        Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}  ${ser_amount3} 
        Should Be Equal As Strings  ${resp.json()['items'][0]['itemId']}  ${itemId}  
        Should Be Equal As Strings  ${resp.json()['items'][0]['price']}  ${it_amount} 
        Should Be Equal As Strings  ${resp.json()['items'][0]['itemName']}  ${DisplayName1} 
        Should Be Equal As Strings  ${resp.json()['items'][0]['quantity']}  1.0
        Should Be Equal As Strings  ${resp.json()['items'][0]['GSTpercentage']}    ${gstper} 

JD-TC- Create Bill -16
        [Documentation]  add more service level discounts
        ${resp}=  Encrypted Provider Login  ${PUSERNAME_Z}  ${PASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME3}
        # Should Be Equal As Strings  ${resp.status_code}  200
        # Set Suite Variable  ${cid}  ${resp.json()[0]['id']}
        ${resp}=  AddCustomer  ${CUSERNAME3}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${cid}  ${resp.json()}
        ${resp}=  Add To Waitlist  ${cid}  ${sid3}  ${qid1}  ${DAY}  ${cnote}  ${bool[1]}  ${cid}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Test Variable  ${wid}  ${wid[0]}
        ${resp}=  Get Bill By UUId  ${wid}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${item}=  Item Bill  my Item  ${itemId}   1
        ${resp}=  Update Bill   ${wid}  ${action[3]}    ${item}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${reason}=   FakerLibrary.word
        ${service}=  Service Bill  ${reason}  ${sid3}  1  ${discountId1}
        ${resp}=  Update Bill   ${wid}  ${action[6]}    ${service}  
        Should Be Equal As Strings  ${resp.status_code}  200
        ${reason}=   FakerLibrary.word
        ${service}=  Service Bill  ${reason}  ${sid3}  1  ${discountId2} 
        ${resp}=  Update Bill   ${wid}  ${action[6]}    ${service}  
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp}=  Get Bill By UUId  ${wid}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${se_netrate}=  Evaluate  ${ser_amount3}-${discamount1}-${discamount2}
        ${taxtot}=  Evaluate  ${se_netrate}+${it_amount}
        ${taxtot}=  Convert To Number  ${taxtot}  2
        ${taxamnt}=  Evaluate  ${taxtot}*${gstper}/100
        ${taxamnt}=  Convert To Number  ${taxamnt}  2
        ${netrate}=  Evaluate  ${it_amount}+${se_netrate}+${taxamnt}
        ${netrate}=  Convert To Number  ${netrate}  2
        Verify Response  ${resp}  uuid=${wid}  netTotal=${taxtot}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  netRate=${netrate}  billPaymentStatus=${paymentStatus[0]}  totalAmountPaid=0.0  amountDue=${netrate}  taxableTotal=${taxtot}  totalTaxAmount=${taxamnt}
        Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${sid3}
        Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE3} 
        Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
        Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}    ${gstper} 
        Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  ${ser_amount3}
        Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}  ${se_netrate}
        Should Be Equal As Strings  ${resp.json()['items'][0]['itemId']}  ${itemId}  
        Should Be Equal As Strings  ${resp.json()['items'][0]['price']}  ${it_amount} 
        Should Be Equal As Strings  ${resp.json()['items'][0]['itemName']}  ${DisplayName1}  
        Should Be Equal As Strings  ${resp.json()['items'][0]['quantity']}  1.0
        Should Be Equal As Strings  ${resp.json()['items'][0]['GSTpercentage']}    ${gstper}
        Should Be Equal As Strings  ${resp.json()['service'][0]['discount'][0]['id']}  ${discountId1}  
        Should Be Equal As Strings  ${resp.json()['service'][0]['discount'][0]['discountValue']}  ${discamount1} 
        Should Be Equal As Strings  ${resp.json()['service'][0]['discount'][1]['id']}  ${discountId2}
        Should Be Equal As Strings  ${resp.json()['service'][0]['discount'][1]['discountValue']}  ${discamount2} 

JD-TC- Create Bill -17
        [Documentation]   add bill level discount
        ${resp}=  Encrypted Provider Login  ${PUSERNAME_Z}  ${PASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME2}
        # Should Be Equal As Strings  ${resp.status_code}  200
        # Set Suite Variable  ${cid}  ${resp.json()[0]['id']}
        ${resp}=  AddCustomer  ${CUSERNAME2}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${cid}  ${resp.json()}
        ${resp}=  Add To Waitlist  ${cid}  ${sid5}  ${qid1}  ${DAY}  ${cnote}  ${bool[1]}  ${cid}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Suite Variable  ${wid}  ${wid[0]}
        ${resp}=  Get Bill By UUId  ${wid}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${item}=  Item Bill  my Item  ${itemId}   1
        ${resp}=  Update Bill   ${wid}  ${action[3]}    ${item}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp}=  Get Bill By UUId  ${wid}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${bid}  ${resp.json()['id']}
        ${disc1}=  Bill Discount Input  ${discountId}  pnote  cnote
        ${bdisc}=  Bill Discount  ${bid}  ${disc1}   
        ${resp}=  Update Bill   ${wid}  ${action[10]}   ${bdisc}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp}=  Get Bill By UUId  ${wid} 
        Should Be Equal As Strings  ${resp.status_code}  200
        ${netTotal}=  Evaluate  ${ser_amount5}+${it_amount}
        ${netTotal}=  Convert To Number  ${netTotal}  2
        ${taxamnt}=  Evaluate  ${it_amount}* ${gstper}/100
        ${taxamnt}=  Convert To Number  ${taxamnt}  2
        ${bill_disc}=  Evaluate  ${netTotal}*${disc_amount}/100
        ${netrate}=  Evaluate  ${netTotal}-${bill_disc}+${taxamnt}
        ${netrate}=  Convert To Number  ${netrate}  2
        Verify Response  ${resp}  uuid=${wid}  netTotal=${netTotal}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  netRate=${netrate}  billPaymentStatus=${paymentStatus[0]}  totalAmountPaid=0.0  amountDue=${netrate}  taxableTotal=${it_amount}  totalTaxAmount=${taxamnt}
        Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${sid5}
        Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE5} 
        Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
        Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}    0.0
        Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  ${ser_amount5}
        Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}  ${ser_amount5} 
        Should Be Equal As Strings  ${resp.json()['items'][0]['itemId']}  ${itemId}  
        Should Be Equal As Strings  ${resp.json()['items'][0]['price']}  ${it_amount} 
        Should Be Equal As Strings  ${resp.json()['items'][0]['itemName']}  ${DisplayName1}
        Should Be Equal As Strings  ${resp.json()['items'][0]['quantity']}  1.0
        Should Be Equal As Strings  ${resp.json()['items'][0]['GSTpercentage']}    ${gstper}
        Should Be Equal As Strings  ${resp.json()['discount'][0]['id']}  ${discountId}  
        Should Be Equal As Strings  ${resp.json()['discount'][0]['discValue']}  ${bill_disc}
        Should Be Equal As Strings  ${resp.json()['discount'][0]['displayNote']}  cnote
        Should Be Equal As Strings  ${resp.json()['discount'][0]['privateNote']}  pnote


JD-TC- Create Bill -UH4

        [Documentation]   add same discount more than once to a bill
        ${resp}=  Encrypted Provider Login  ${PUSERNAME_Z}  ${PASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp}=  Get Bill By UUId  ${wid}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${bid}  ${resp.json()['id']}
        ${disc1}=  Bill Discount Input  ${discountId}  pnote  cnote
        ${bdisc}=  Bill Discount  ${bid}  ${disc1}   
        ${resp}=  Update Bill   ${wid}  ${action[10]}   ${bdisc} 
        Should Be Equal As Strings  ${resp.status_code}  422
        Should Be Equal As Strings  "${resp.json()}"  "${DISCOUNT_ALREADY_USED}"

JD-TC- Create Bill -18

        [Documentation]   remove bill level discount
        ${resp}=  Encrypted Provider Login  ${PUSERNAME_Z}  ${PASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp}=  Get Bill By UUId  ${wid}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${bid}  ${resp.json()['id']}
        ${bdisc}=  Remove Bill Discount  ${bid}  ${discountId} 
        ${resp}=  Update Bill   ${wid}  ${action[11]}   ${bdisc}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp}=  Get Bill By UUId  ${wid}
        Should Be Equal As Strings  ${resp.status_code}  200  
        ${netTotal}=  Evaluate  ${ser_amount5}+${it_amount}
        ${netTotal}=  Convert To Number  ${netTotal}  2
        ${taxamnt}=  Evaluate  ${it_amount}* ${gstper}/100
        ${taxamnt}=  Convert To Number  ${taxamnt}  2
        ${netrate}=  Evaluate  ${netTotal}+${taxamnt}
        ${netrate}=  Convert To Number  ${netrate}  2
        Verify Response  ${resp}  uuid=${wid}  netTotal=${netTotal}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  netRate=${netrate}  billPaymentStatus=${paymentStatus[0]}  totalAmountPaid=0.0  amountDue=${netrate}  taxableTotal=${it_amount}  totalTaxAmount=${taxamnt}
        Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${sid5}
        Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE5} 
        Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
        Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}    0.0 
        Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  ${ser_amount5}
        Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}  ${ser_amount5}
        Should Be Equal As Strings  ${resp.json()['items'][0]['itemId']}  ${itemId}  
        Should Be Equal As Strings  ${resp.json()['items'][0]['price']}  ${it_amount} 
        Should Be Equal As Strings  ${resp.json()['items'][0]['itemName']}  ${DisplayName1}
        Should Be Equal As Strings  ${resp.json()['items'][0]['quantity']}  1.0
        Should Be Equal As Strings  ${resp.json()['items'][0]['GSTpercentage']}    ${gstper}


JD-TC- Create Bill -19

        [Documentation]  add more bill level discounts
        ${resp}=  Encrypted Provider Login  ${PUSERNAME_Z}  ${PASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME4}
        # Should Be Equal As Strings  ${resp.status_code}  200
        # Set Test Variable  ${cid}  ${resp.json()[0]['id']}
        ${resp}=  Add To Waitlist  ${cid}  ${sid2}  ${qid1}  ${DAY}  ${cnote}  ${bool[1]}  ${cid}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Test Variable  ${wid}  ${wid[0]}
        ${resp}=  Get Bill By UUId  ${wid}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${item}=  Item Bill  my Item  ${itemId}   1
        ${resp}=  Update Bill   ${wid}  ${action[3]}    ${item}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp}=  Get Bill By UUId  ${wid}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${bid}  ${resp.json()['id']}
        ${disc1}=  Bill Discount Input  ${discountId1}  pnote  cnote
        ${bdisc}=  Bill Discount  ${bid}  ${disc1}  
        ${resp}=  Update Bill   ${wid}  ${action[10]}   ${bdisc}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${disc2}=  Bill Discount Input  ${discountId2}  pnote1  cnote1
        ${bdisc}=  Bill Discount  ${bid}  ${disc2}  
        ${resp}=  Update Bill   ${wid}  ${action[10]}   ${bdisc}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp}=  Get Bill By UUId  ${wid}     
        Should Be Equal As Strings  ${resp.status_code}  200
        ${netTotal}=  Evaluate  ${ser_amount2}+${it_amount}
        ${netTotal}=  Convert To Number  ${netTotal}  2
        ${totalDiscount}=  Evaluate  ${discamount1}+${discamount2}
        ${taxabletotal}=  Evaluate  ${netTotal}-${totalDiscount}
        ${taxabletotal}=  Convert To Number  ${taxabletotal}  2
        ${taxamnt}=  Evaluate  ${taxabletotal}*${gstper}/100
        ${taxamnt}=  Convert To Number  ${taxamnt}  2
        # ${netrate}=  Evaluate  ${netTotal}-${discamount1}-${discamount2}+${taxamnt}
        ${netRate}=  Evaluate  ${taxabletotal}+${taxamnt}
        ${netRate}=  Convert To Number  ${netRate}  2
        Verify Response  ${resp}  uuid=${wid}  netTotal=${netTotal}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  netRate=${netrate}  billPaymentStatus=${paymentStatus[0]}  totalAmountPaid=0.0  amountDue=${netrate}  taxableTotal=${taxabletotal}  totalTaxAmount=${taxamnt}
        Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${sid2}
        Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE2} 
        Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
        Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}    ${gstper} 
        Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  ${ser_amount2}
        Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}  ${ser_amount2}
        Should Be Equal As Strings  ${resp.json()['items'][0]['itemId']}  ${itemId}  
        Should Be Equal As Strings  ${resp.json()['items'][0]['price']}  ${it_amount}  
        Should Be Equal As Strings  ${resp.json()['items'][0]['itemName']}  ${DisplayName1}
        Should Be Equal As Strings  ${resp.json()['items'][0]['quantity']}  1.0
        Should Be Equal As Strings  ${resp.json()['items'][0]['GSTpercentage']}    ${gstper}
        Should Be Equal As Strings  ${resp.json()['discount'][0]['id']}  ${discountId1}
        Should Be Equal As Strings  ${resp.json()['discount'][0]['discValue']}  ${discamount1}
        Should Be Equal As Strings  ${resp.json()['discount'][0]['displayNote']}  cnote
        Should Be Equal As Strings  ${resp.json()['discount'][0]['privateNote']}  pnote
        Should Be Equal As Strings  ${resp.json()['discount'][1]['id']}  ${discountId2}
        Should Be Equal As Strings  ${resp.json()['discount'][1]['discValue']}  ${discamount2}
        Should Be Equal As Strings  ${resp.json()['discount'][1]['displayNote']}  cnote1
        Should Be Equal As Strings  ${resp.json()['discount'][1]['privateNote']}  pnote1


JD-TC- Create Bill -20

        [Documentation]    add discount and coupon to netBill
        
        ${resp}=  Encrypted Provider Login  ${PUSERNAME_Z}  ${PASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME2}
        # Should Be Equal As Strings  ${resp.status_code}  200
        # Set Test Variable  ${cid}  ${resp.json()[0]['id']}
       
        ${resp}=  Add To Waitlist  ${cid}  ${sid3}  ${qid1}  ${DAY}  ${cnote}  ${bool[1]}  ${cid}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Test Variable  ${wid1}  ${wid[0]}
        ${resp}=  Get Bill By UUId  ${wid1}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${item}=  Item Bill  my Item  ${itemId}   2
        ${resp}=  Update Bill   ${wid1}  ${action[3]}    ${item}
        Should Be Equal As Strings  ${resp.status_code}  200
       
        ${resp}=  Get Bill By UUId  ${wid1}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${bid}  ${resp.json()['id']}
        # ${coupon}=  Provider Coupons  ${bid}  ${couponId}
       
       ${resp}=  Update Bill   ${wid1}  ${action[12]}    ${cupn_code}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${disc1}=  Bill Discount Input  ${discountId}  pnote  cnote
        ${bdisc}=  Bill Discount  ${bid}  ${disc1}   
       
        ${resp}=  Update Bill   ${wid1}  ${action[10]}   ${bdisc}
        Should Be Equal As Strings  ${resp.status_code}  200
        
        ${resp}=  Get Bill By UUId  ${wid1}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${netTotal}=  Evaluate  ${ser_amount3}+(2*${it_amount})
        ${netTotal}=  Convert To Number  ${netTotal}  2
        ${bill_disc}=  Evaluate  ${netTotal}*${disc_amount}/100
        ${totalDiscount}=  Evaluate  ${bill_disc}+${cou_amount}
        ${taxabletotal}=  Evaluate  ${netTotal}-${totalDiscount}
        ${taxabletotal}=  Convert To Number  ${taxabletotal}  2
        ${taxamnt}=  Evaluate  ${taxabletotal}*${gstper}/100
        ${taxamnt}=  Convert To Number  ${taxamnt}  2
        # ${netrate}=  Evaluate  ${netTotal}+${taxamnt}-${cou_amount}-${bill_disc}
        ${netRate}=  Evaluate  ${taxabletotal}+${taxamnt}
        ${netRate}=  Convert To Number  ${netRate}  2
        Verify Response  ${resp}  uuid=${wid1}  netTotal=${netTotal}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  netRate=${netrate}  billPaymentStatus=${paymentStatus[0]}  totalAmountPaid=0.0  amountDue=${netrate}  taxableTotal=${taxabletotal}  totalTaxAmount=${taxamnt}        
        Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${sid3}
        Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE3} 
        Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
        Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}    ${gstper} 
        Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  ${ser_amount3}
        Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}  ${ser_amount3}
        Should Be Equal As Strings  ${resp.json()['items'][0]['itemId']}  ${itemId}  
        Should Be Equal As Strings  ${resp.json()['items'][0]['price']}  ${it_amount} 
        Should Be Equal As Strings  ${resp.json()['items'][0]['itemName']}  ${DisplayName1}
        Should Be Equal As Strings  ${resp.json()['items'][0]['quantity']}  2.0
        Should Be Equal As Strings  ${resp.json()['items'][0]['GSTpercentage']}    ${gstper}
        Should Be Equal As Strings  ${resp.json()['discount'][0]['id']}  ${discountId}  
        Should Be Equal As Strings  ${resp.json()['discount'][0]['discValue']}  ${bill_disc}    
        Should Be Equal As Strings  ${resp.json()['providerCoupon']['${cupn_code}']['value']}  ${cou_amount}  

JD-TC- Create Bill -21

        [Documentation]    Create Bill with more discounts and coupons applied to netBill
        ${data}=  FakerLibrary.Word
        ${resp}=  Encrypted Provider Login  ${PUSERNAME_Z}  ${PASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        # ${maxval}=  Evaluate  ${ser_amount5}/2
        # ${maxval}=   Convert To Integer  ${maxval}
        # ${coupon1_amt}=  Random Int   min=10   max=100
        # ${coupon1_amt}=   Convert To Number   ${coupon1_amt}
        # ${resp}=  Create Coupon  coupon22  ${data}  ${coupon1_amt}  ${calc_mode[1]} 
        # Should Be Equal As Strings  ${resp.status_code}  200
        # Set Suite Variable  ${couponId1}  ${resp.json()}
        # ${coupon2_amt}=  Random Int   min=1   max=10
        # ${coupon2_amt}=   Convert To Number   ${coupon2_amt}
        # ${resp}=  Create Coupon  coupon33  ${data}  ${coupon2_amt}  ${calctype[0]}
        # Should Be Equal As Strings  ${resp.status_code}  200
        # Set Suite Variable  ${couponId2}  ${resp.json()}


        ${coupon}=    FakerLibrary.word
        ${desc}=  FakerLibrary.Sentence   nb_words=2
        ${coupon1_amt}=  Random Int   min=10   max=100
        ${coupon1_amt}=   Convert To Number   ${coupon1_amt}
        ${cupn_code1}=   FakerLibrary.word
        ${list}=  Create List  1  2  3  4  5  6  7
        ${sTime}=  db.subtract_timezone_time  ${tz}  0  15
        ${eTime}=  add_timezone_time  ${tz}  0  45  
        ${ST_DAY}=  db.get_date_by_timezone  ${tz}
        ${EN_DAY}=  db.add_timezone_date  ${tz}   10
        ${min_bill_amount}=   Random Int   min=10   max=50
        ${max_disc_val1}=   Random Int   min=50   max=100
        ${max_prov_use}=   Random Int   min=10   max=20
        ${book_channel}=   Create List   ${bookingChannel[0]}
        ${coupn_based}=  Create List   ${couponBasedOn[0]}
        ${tc}=  FakerLibrary.sentence
        ${services}=   Create list   ${sid1}   ${sid2}  ${sid3}   ${sid4}   ${sid5}
        ${items}=   Create List   ${itemId}
        ${resp}=  Create Provider Coupon   ${coupon}  ${desc}  ${coupon1_amt}  ${calctype[1]}  ${cupn_code1}  ${recurringtype[1]}  ${list}  ${sTime}  ${eTime}  ${ST_DAY}  ${EN_DAY}  ${EMPTY}  ${bool[0]}  ${min_bill_amount}  ${max_disc_val1}  ${bool[1]}  ${max_prov_use}  ${book_channel}  ${coupn_based}  ${tc}  services=${services}  items=${items} 
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${couponId1}  ${resp.json()}
        

        ${coupon}=    FakerLibrary.name
        ${desc}=  FakerLibrary.Sentence   nb_words=2
        ${coupon2_amt}=  Random Int   min=1   max=10
        ${coupon2_amt}=   Convert To Number   ${coupon2_amt}
        ${cupn_code2}=   FakerLibrary.word
        ${list}=  Create List  1  2  3  4  5  6  7
        ${sTime}=  db.subtract_timezone_time  ${tz}  0  15
        ${eTime}=  add_timezone_time  ${tz}  0  45  
        ${ST_DAY}=  db.get_date_by_timezone  ${tz}
        ${EN_DAY}=  db.add_timezone_date  ${tz}   10
        ${min_bill_amount}=   Random Int   min=10   max=50
        ${max_disc_val2}=   Random Int   min=50   max=100
        ${max_prov_use}=   Random Int   min=10   max=20
        ${book_channel}=   Create List   ${bookingChannel[0]}
        ${coupn_based}=  Create List   ${couponBasedOn[0]}
        ${tc}=  FakerLibrary.sentence
        ${services}=   Create list   ${sid1}   ${sid2}  ${sid3}  ${sid4}   ${sid5}
        ${items}=   Create List   ${itemId}
        ${resp}=  Create Provider Coupon   ${coupon}  ${desc}  ${coupon2_amt}  ${calctype[0]}  ${cupn_code2}  ${recurringtype[1]}  ${list}  ${sTime}  ${eTime}  ${ST_DAY}  ${EN_DAY}  ${EMPTY}  ${bool[0]}  ${min_bill_amount}  ${max_disc_val2}  ${bool[1]}  ${max_prov_use}  ${book_channel}  ${coupn_based}  ${tc}  services=${services}  items=${items} 
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${couponId2}  ${resp.json()}
        
        # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME5}  
        # Should Be Equal As Strings  ${resp.status_code}  200
        # Set Suite Variable  ${cid}  ${resp.json()[0]['id']}
        ${resp}=  AddCustomer  ${CUSERNAME5}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${cid}  ${resp.json()}

        ${resp}=  Get Bill By UUId  ${wid}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${item}=  Item Bill  my Item  ${itemId}   2

        ${resp}=  Update Bill   ${wid}  ${action[3]}    ${item}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=  Get Bill By UUId  ${wid}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${bid}  ${resp.json()['id']}

        ${disc1}=  Bill Discount Input  ${discountId1}  pnote  cnote
        ${bdisc}=  Bill Discount  ${bid}  ${disc1}  

        ${resp}=  Update Bill   ${wid}  ${action[10]}   ${bdisc}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${disc2}=  Bill Discount Input  ${discountId2}  pnote1  cnote1
        ${bdisc}=  Bill Discount  ${bid}  ${disc2}  

        ${resp}=  Update Bill   ${wid}  ${action[10]}   ${bdisc}
        Should Be Equal As Strings  ${resp.status_code}  200

        # ${coupon}=  Provider Coupons  ${bid}  ${couponId1}
        ${resp}=  Update Bill   ${wid}  ${action[12]}    ${cupn_code1}
        Should Be Equal As Strings  ${resp.status_code}  200

        # ${coupon}=  Provider Coupons  ${bid}  ${couponId2}
        ${resp}=  Update Bill   ${wid}  ${action[12]}    ${cupn_code2}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${netRate1}  ${resp.json()['amountDue']}

        comment   service5 is not taxable

        ${netTotal}=  Evaluate  ${ser_amount5}+(3*${it_amount})
        ${netTotal}=  Convert To Number  ${netTotal}  2
        ${Discount}=  Evaluate  ${discamount1}+${discamount2}+${coupon1_amt}
        ${amount}=  Evaluate  ${netTotal}-${Discount}
        ${coupon_disc}=  Evaluate  ${amount}*${coupon2_amt}/100
        ${coupon_disc}=   Set Variable If  ${coupon_disc} > ${max_disc_val2}   ${max_disc_val2}   ${coupon_disc}
        ${coupon_disc}=  Convert To Number  ${coupon_disc}  2
        ${totalDiscount}=  Evaluate  ${Discount}+${coupon_disc}
        ${taxabletotal}=  Evaluate  ${it_amount}*3
        ${taxamnt}=  Evaluate  ${taxabletotal}*${gstper}/100
        ${taxamnt}=  Convert To Number  ${taxamnt}  2
        ${netRate}=  Evaluate  ${netTotal}-${totalDiscount}+${taxamnt}
        ${netRate}=  Convert To Number  ${netRate}  2
        ${resp}=  Get Bill By UUId  ${wid}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  uuid=${wid}  netTotal=${netTotal}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  netRate=${netRate1}  billPaymentStatus=${paymentStatus[0]}  totalAmountPaid=0.0   amountDue=${netRate1}   taxableTotal=${taxabletotal}  totalTaxAmount=${taxamnt}
        Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${sid5}  
        Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  ${ser_amount5}
        Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
        Should Be Equal As Strings  ${resp.json()['items'][0]['itemId']}  ${itemId}  
        Should Be Equal As Strings  ${resp.json()['items'][0]['price']}  ${it_amount}
        Should Be Equal As Strings  ${resp.json()['items'][0]['quantity']}  3.0
        Should Be Equal As Strings  ${resp.json()['discount'][0]['id']}  ${discountId1}
        Should Be Equal As Strings  ${resp.json()['discount'][0]['discValue']}  ${discamount1} 
        Should Be Equal As Strings  ${resp.json()['discount'][0]['displayNote']}  cnote
        Should Be Equal As Strings  ${resp.json()['discount'][0]['privateNote']}  pnote
        Should Be Equal As Strings  ${resp.json()['discount'][1]['id']}  ${discountId2}
        Should Be Equal As Strings  ${resp.json()['discount'][1]['discValue']}  ${discamount2}
        Should Be Equal As Strings  ${resp.json()['discount'][1]['displayNote']}  cnote1
        Should Be Equal As Strings  ${resp.json()['discount'][1]['privateNote']}  pnote1
        # Should Be Equal As Strings  ${resp.json()['providerCoupon'][0]['id']}  ${couponId1}  
        # Should Be Equal As Strings  ${resp.json()['providerCoupon'][0]['couponValue']}  ${coupon1_amt} 
        # Should Be Equal As Strings  ${resp.json()['providerCoupon'][1]['id']}  ${couponId2}  
        # Should Be Equal As Strings  ${resp.json()['providerCoupon'][1]['couponValue']}  ${coupon_disc}  

        # Should Be Equal As Strings  ${resp.json()['providerCoupon'][0]['${cupn_code1}']['value']}  ${coupon1_amt}  
        # Should Be Equal As Strings  ${resp.json()['providerCoupon'][1]['${cupn_code2}']['value']}  ${coupon_disc}
        Should Be Equal As Strings  ${resp.json()['providerCoupon']['${cupn_code1}']['value']}  ${coupon1_amt}  
        Should Be Equal As Strings  ${resp.json()['providerCoupon']['${cupn_code2}']['value']}  ${coupon_disc}  

JD-TC- Create Bill -22

        [Documentation]   add adhoc discount
        ${resp}=  Encrypted Provider Login  ${PUSERNAME_Z}  ${PASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME1}   
        # Should Be Equal As Strings  ${resp.status_code}  200
        # Set Suite Variable  ${cid}  ${resp.json()[0]['id']}
        ${resp}=  AddCustomer  ${CUSERNAME1}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${cid}  ${resp.json()}
        ${resp}=  Add To Waitlist  ${cid}  ${sid3}  ${qid1}  ${DAY}  ${cnote}  ${bool[1]}  ${cid}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Suite Variable  ${wid2}  ${wid[0]}
        ${resp}=  Get discounts
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${addiscount}  ${resp.json()[0]['id']}
        ${resp}=  Get Bill By UUId  ${wid2}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${bid}  ${resp.json()['id']}
        ${tamount}=  Evaluate  ${ser_amount3}/2
        ${tamount}=   Convert To Integer   ${tamount}

        ${ad_amount}=   Random Int   min=1   max=${tamount}
        ${ad_amount}=   Convert To Number   ${ad_amount}
        ${disc1}=  Bill Discount Adhoc Input  ${addiscount}  pnote  cnote  ${ad_amount}
        ${bdisc}=  Bill Discount  ${bid}  ${disc1}   
        ${resp}=  Update Bill   ${wid2}  ${action[10]}   ${bdisc}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp}=  Get Bill By UUId  ${wid2} 
        Should Be Equal As Strings  ${resp.status_code}  200
        ${taxtot}=  Evaluate  ${ser_amount3}-${ad_amount}
        ${taxtot}=  Convert To Number  ${taxtot}  2
        ${taxamnt}=  Evaluate  ${taxtot}* ${gstper}/100
        ${taxamnt}=  Convert To Number  ${taxamnt}  2
        ${netrate}=  Evaluate  ${taxtot}+${taxamnt}
        ${netRate}=  Convert To Number  ${netRate}  2
        Verify Response  ${resp}  uuid=${wid2}  netTotal=${ser_amount3}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  netRate=${netrate}  billPaymentStatus=${paymentStatus[0]}  totalAmountPaid=0.0  amountDue=${netrate}  taxableTotal=${taxtot}  totalTaxAmount=${taxamnt}
        Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${sid3}
        Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE3} 
        Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
        Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}    ${gstper} 
        Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  ${ser_amount3}
        Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}  ${ser_amount3}
        Should Be Equal As Strings  ${resp.json()['discount'][0]['id']}  ${addiscount}
        Should Be Equal As Strings  ${resp.json()['discount'][0]['discValue']}  ${ad_amount}

JD-TC- Create Bill -23

        [Documentation]  remove adhoc discount
        ${resp}=  Encrypted Provider Login  ${PUSERNAME_Z}  ${PASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp}=  Get Bill By UUId  ${wid2}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${bid}  ${resp.json()['id']}
        ${bdisc}=  Remove Bill Discount  ${bid}  ${addiscount} 
        ${resp}=  Update Bill   ${wid2}  ${action[11]}   ${bdisc}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp}=  Get Bill By UUId  ${wid2}
        Should Be Equal As Strings  ${resp.status_code}  200 
        ${taxamnt}=  Evaluate  ${ser_amount3}* ${gstper}/100
        ${taxamnt}=  Convert To Number  ${taxamnt}  2
        ${taxamnt}=  Convert To Number  ${taxamnt}  2
        ${netrate}=  Evaluate  ${ser_amount3}+${taxamnt}
        ${netRate}=  Convert To Number  ${netRate}  2
        Verify Response  ${resp}  uuid=${wid2}  netTotal=${ser_amount3}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  netRate=${netrate}  billPaymentStatus=${paymentStatus[0]}  totalAmountPaid=0.0  amountDue=${netrate}  taxableTotal=${ser_amount3}  totalTaxAmount=${taxamnt}
        Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${sid3}
        Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE3} 
        Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
        Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}    ${gstper} 
        Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  ${ser_amount3}
        Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}  ${ser_amount3}

JD-TC- Create Bill -24

        [Documentation]   add adhoc discount(taxable item and non taxable service)
        ${resp}=  Encrypted Provider Login  ${PUSERNAME_Z}  ${PASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME1}   
        # Should Be Equal As Strings  ${resp.status_code}  200
        # Set Suite Variable  ${cid}  ${resp.json()[0]['id']}
        ${resp}=  Add To Waitlist  ${cid}  ${sid4}  ${qid1}  ${DAY}  ${cnote}  ${bool[1]}  ${cid}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Suite Variable  ${wid2}  ${wid[0]}
        ${resp}=  Get discounts
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${addiscount}  ${resp.json()[0]['id']}
        Set Suite Variable  ${calculationtype}  ${resp.json()[0]['calculationType']}
        ${resp}=  Get Bill By UUId  ${wid2}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${bid}  ${resp.json()['id']}
        ${item}=  Item Bill  my Item  ${itemId}   1
        ${resp}=  Update Bill   ${wid2}  ${action[3]}    ${item}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${tamount}=  Evaluate  ${ser_amount3}/2
        ${tamount}=   Convert To Integer   ${tamount}
        ${ad_amount}=   Random Int   min=1   max=${tamount}
        ${ad_amount}=   Convert To Number   ${ad_amount}
        ${disc1}=  Bill Discount Adhoc Input  ${addiscount}  pnote  cnote  ${ad_amount}
        ${bdisc}=  Bill Discount  ${bid}  ${disc1}   
        ${resp}=  Update Bill   ${wid2}  ${action[10]}   ${bdisc}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp}=  Get Bill By UUId  ${wid2} 
        Should Be Equal As Strings  ${resp.status_code}  200
        ${netTotal}=  Evaluate  ${ser_amount4}+${it_amount}
        ${netTotal}=  Convert To Number  ${netTotal}  2
        ${taxamnt}=  Evaluate  ${it_amount}* ${gstper}/100
        ${taxamnt}=  Convert To Number  ${taxamnt}  2
        Log Many  ${calculationtype} 	${calctype[0]}   ${netTotal} 	${disc_amount} 	${ad_amount}
        ${bill_disc}=  Run Keyword If  '${calculationtype}' == '${calctype[0]}'   Evaluate  ${netTotal}*${disc_amount}/100
        ...            ELSE   Set Variable  ${ad_amount}
        ${netrate}=  Evaluate  ${netTotal}-${bill_disc}+${taxamnt}
        ${netRate}=  Convert To Number  ${netRate}  2
        Verify Response  ${resp}  uuid=${wid2}  netTotal=${netTotal}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  netRate=${netrate}  billPaymentStatus=${paymentStatus[0]}  totalAmountPaid=0.0  amountDue=${netrate}  taxableTotal=${it_amount}  totalTaxAmount=${taxamnt}
        Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${sid4}
        Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE4} 
        Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
        Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}    0.0 
        Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  ${ser_amount4}
        Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}  ${ser_amount4}
        Should Be Equal As Strings  ${resp.json()['items'][0]['itemId']}  ${itemId}  
        Should Be Equal As Strings  ${resp.json()['items'][0]['price']}  ${it_amount} 
        Should Be Equal As Strings  ${resp.json()['items'][0]['itemName']}  ${DisplayName1}
        Should Be Equal As Strings  ${resp.json()['items'][0]['quantity']}  1.0
        Should Be Equal As Strings  ${resp.json()['items'][0]['GSTpercentage']}    ${gstper}
        Should Be Equal As Strings  ${resp.json()['discount'][0]['id']}  ${addiscount}
        Should Be Equal As Strings  ${resp.json()['discount'][0]['discValue']}  ${ad_amount}

JD-TC- Create Bill -25

        [Documentation]   Bill generated in family member's name if booking is for family member
        ...    Get Bill
      

        ${resp}=  Encrypted Provider Login  ${PUSERNAME_Z}  ${PASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=  Get Consumer By Id  ${CUSERNAME8}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${jdconID}   ${resp.json()['id']}
        Set Test Variable  ${Con_firstName}   ${resp.json()['userProfile']['firstName']}
        Set Test Variable  ${Con_lastName}   ${resp.json()['userProfile']['lastName']}
        Set Test Variable  ${cid}  ${resp.json()['userProfile']['id']}
        # clear_service   ${PUSERNAME_Z}
        # clear_location  ${PUSERNAME_Z}
        # clear_queue      ${PUSERNAME_Z}
        # clear_appt_schedule   ${PUSERNAME_Z}
        # clear_customer   ${PUSERNAME_Z}

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
        ${sTime1}=  db.add_timezone_time  ${tz}  0  15
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

        ${resp}=  AddCustomer  ${CUSERNAME8}   firstName=${Con_firstName}   lastName=${Con_lastName}
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

        # # ${resp}=  Get Bill By UUId  ${apptid4}
        # # Log   ${resp.json()}

        # # ${reason}=  Random Element  ${cancelReason}
        # # ${cancel_msg}=   FakerLibrary.word
        # # ${resp}=    Provider Cancel Appointment  ${apptid1}  ${reason}  ${cancel_msg}  ${DAY1}
        # # Log   ${resp.json()}
        # # Should Be Equal As Strings  ${resp.status_code}  200

        # # sleep  02s

        # ${resp}=  Get Appointment By Id   ${apptid1}
        # Log   ${resp.json()}
        # Should Be Equal As Strings  ${resp.status_code}  200
        # Verify Response  ${resp}  uid=${apptid1}  appointmentEncId=${encId1}  appmtDate=${DAY1}  appmtTime=${slot1}  apptBy=PROVIDER   paymentStatus=${paymentStatus[2]}  appointmentMode=${appointmentMode[0]}  apptStatus=${apptStatus[4]}

        # ${resp}=  Get Appointment By Id   ${apptid2}
        # Log   ${resp.json()}
        # Should Be Equal As Strings  ${resp.status_code}  200
        # Verify Response  ${resp}  uid=${apptid2}  appointmentEncId=${encId2}  appmtDate=${DAY1}  appmtTime=${slot2}  apptBy=PROVIDER   paymentStatus=${paymentStatus[2]}  appointmentMode=${appointmentMode[0]}  apptStatus=${apptStatus[1]}

        # ${resp}=  Get Appointment By Id   ${apptid3}
        # Log   ${resp.json()}
        # Should Be Equal As Strings  ${resp.status_code}  200
        # Verify Response  ${resp}  uid=${apptid3}  appointmentEncId=${encId3}  appmtDate=${DAY1}  appmtTime=${slot3}  apptBy=PROVIDER   paymentStatus=${paymentStatus[2]}  appointmentMode=${appointmentMode[0]}  apptStatus=${apptStatus[1]}

        # ${resp}=  Get Appointment By Id   ${apptid4}
        # Log   ${resp.json()}
        # Should Be Equal As Strings  ${resp.status_code}  200
        # Verify Response  ${resp}  uid=${apptid4}  appointmentEncId=${encId4}  appmtDate=${DAY1}  appmtTime=${slot4}  apptBy=PROVIDER   paymentStatus=${paymentStatus[2]}  appointmentMode=${appointmentMode[0]}  apptStatus=${apptStatus[1]}

        ${resp}=  Get Bill By UUId  ${apptid1}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
       

        ${netRate}=   Evaluate   ${service_charge}*3
        ${netrate}=  Convert To Number  ${netrate}  2

        ${resp}=  Get Bill By UUId  ${apptid2}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()['uuid']}         ${apptid2}
        Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}         ${netRate}
        Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}         3.0


JD-TC- Create Bill -26

        [Documentation]   consumer takes checkin for self and family members
        ...    Get Bill

        ${resp}=  Consumer Login  ${CUSERNAME12}  ${PASSWORD}
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200
        Set Test Variable  ${jdconID}   ${resp.json()['id']}
        Set Test Variable  ${firstName}   ${resp.json()['firstName']}
        Set Test Variable  ${lastName}   ${resp.json()['lastName']}
        Set Test Variable  ${cid}  ${resp.json()}  
         ${DAY}=  db.get_date_by_timezone  ${tz}
        Set Suite Variable  ${DAY}

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
                ${resp}=  Encrypted Provider Login  ${PUSERNAME_Z}  ${PASSWORD}
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


        # ${pkg_id}=   get_highest_license_pkg
        # ${resp}=  Change License Package  ${pkgid[0]}
        # Should Be Equal As Strings    ${resp.status_code}   200

        ${resp}=  Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${boolean[0]}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
    
        ${resp}=  Get jaldeeIntegration Settings
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}

       ${resp}=  AddCustomer  ${CUSERNAME12}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${cid}  ${resp.json()}   

        ${resp}=  Create Sample Queue  
        Set Test Variable  ${qid1}   ${resp['queue_id']}
        Set Test Variable  ${sid1}   ${resp['service_id']}
        Set Test Variable  ${lid}   ${resp['location_id']}
        Set Test Variable  ${s_name}   ${resp['service_name']}

        ${resp}=   Get Service
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()[0]['id']}   ${sid1}
        Set Test Variable   ${service_charge}   ${resp.json()[0]['totalAmount']}

        # ${resp}=    Get Locations
        # Log   ${resp.json()}
        # Should Be Equal As Strings  ${resp.status_code}  200
        # Should Be Equal As Strings  ${resp.json()[0]['id']}   ${lid}
        # # Set Test Variable   ${lid1}   ${resp.json()[0]['id']}

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

        ${resp}=  Add To Waitlist  ${cid}  ${sid1}  ${qid1}  ${DAY}  ${cnote}  ${bool[1]}  ${cid}
        Log  ${resp.json()} 
        Should Be Equal As Strings  ${resp.status_code}  200
         Set Test Variable  ${wait_id1}  ${resp.json()['parent_uuid']}

        ${resp}=  Add To Waitlist  ${cid}  ${sid1}  ${qid1}  ${DAY}  ${cnote}  ${bool[1]}  ${mem_id1}
        Log  ${resp.json()} 
        Should Be Equal As Strings  ${resp.status_code}  200
         Set Test Variable  ${wait_id2}  ${resp.json()['parent_uuid']}
        
      
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
        # Should Be Equal As Strings  ${resp.json()['parentUuid']}                      ${wait_id1}
        Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${mem_id1}


        ${netRate}=   Evaluate   ${service_charge}*4

        ${resp}=  Get Bill By UUId  ${wait_id1}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()['uuid']}         ${wait_id1}
        # Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}         ${netRate}
        # Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}         4.0
        
        ${resp}=  Get Bill By UUId  ${wait_id2}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()['uuid']}         ${wait_id2}
        Should Be Equal As Strings  ${resp.json()['providerConsumer']['firstName']}         ${firstname1}
        should Be Equal As Strings  ${resp.json()['providerConsumer']['lastName']}         ${lastName1}

        
JD-TC- Create Bill -UH5

        [Documentation]  Create Bill for canceld waitlist
        ${data}=  FakerLibrary.Word
        ${resp}=  Encrypted Provider Login  ${PUSERNAME_Z}  ${PASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME2}
        # Should Be Equal As Strings  ${resp.status_code}  200
        # Set Suite Variable  ${cid}  ${resp.json()[0]['id']}
        # Set Suite Variable  ${cid}
        ${resp}=  Add To Waitlist  ${cid}  ${sid2}  ${qid1}  ${DAY}  ${cnote}  ${bool[1]}  ${cid}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Test Variable  ${wid}  ${wid[0]}
        ${cancel}    Random Element    ${cancelReason} 
        ${msg}=  Fakerlibrary.word
        Append To File  ${EXECDIR}/TDD/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
        ${resp}=  Waitlist Action Cancel  ${wid}  ${cancel}   ${msg} 
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp}=  Get Bill By UUId  ${wid}   
        Should Be Equal As Strings  ${resp.status_code}  422
        Should Be Equal As Strings  "${resp.json()}"  "${CANCELLED_WAITLIST}"


JD-TC- Create Bill -UH6
        [Documentation]  Create Bill with another provider's item
        ${data}=  FakerLibrary.Word
        clear_Item    ${PUSERNAME4}
        ${resp}=  Encrypted Provider Login  ${PUSERNAME4}  ${PASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${it_amount3}=   Random Int   min=100   max=500
        ${it_amount3}=   Convert To Number   ${it_amount}
        # ${resp}=  Create Item   ${item4}  ${data}   ${data}   ${it_amount3}  ${bool[0]} 
        ${resp}=  Create Sample Item   ${DisplayName4}  ${item4}  ${itemCode4}  ${it_amount3}  ${bool[0]}        
        Should Be Equal As Strings  ${resp.status_code}   200
        Set Test Variable  ${itemId}  ${resp.json()}
        ${resp}=  Encrypted Provider Login  ${PUSERNAME_Z}  ${PASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp}=  Add To Waitlist  ${cid}  ${sid1}  ${qid1}  ${DAY}  ${cnote}  ${bool[1]}  ${cid}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Test Variable  ${wid}  ${wid[0]}
        ${resp}=  Get Bill By UUId  ${wid}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${item}=  Item Bill  my Item  ${itemId}   1
        ${resp}=  Update Bill   ${wid}  ${action[3]}    ${item}   
        Should Be Equal As Strings  ${resp.status_code}  422
        Should Be Equal As Strings  "${resp.json()}"  "${NO_ITEMS_FOUND}"
        ${cancel}    Random Element     ${cancelReason} 
        ${msg}=  Fakerlibrary.word
        Append To File  ${EXECDIR}/TDD/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
        ${resp}=  Waitlist Action Cancel  ${wid}  ${cancel}  ${msg} 
        Should Be Equal As Strings  ${resp.status_code}  200 


JD-TC- Create Bill -UH7

        [Documentation]  Create Bill with another provider's discount
        ${data}=  FakerLibrary.Word
        clear_Discount    ${PUSERNAME2}
        ${resp}=  Encrypted Provider Login  ${PUSERNAME2}  ${PASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp}=   Create Discount   ${discount4}     ${data}    100.0   ${calc_mode[1]}   Predefine
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable   ${discountId}   ${resp.json()}
        ${resp}=  ProviderLogout    
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp}=  Encrypted Provider Login  ${PUSERNAME_Z}  ${PASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME4}
        # Should Be Equal As Strings  ${resp.status_code}  200
        # Set Suite Variable  ${cid}  ${resp.json()[0]['id']}
        ${DAY}=  db.add_timezone_date  ${tz}  2  
        Set Suite Variable   ${DAY}  ${DAY} 
        ${resp}=  Add To Waitlist  ${cid}  ${sid3}  ${qid1}  ${DAY}  ${cnote}  ${bool[1]}  ${cid}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Suite Variable  ${wid}  ${wid[0]}
        ${resp}=  Get Bill By UUId  ${wid}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${bid}  ${resp.json()['id']}
        ${disc1}=  Bill Discount Input  ${discountId}  pnote  cnote
        ${bdisc}=  Bill Discount  ${bid}  ${disc1}  
        ${resp}=  Update Bill   ${wid}  ${action[10]}   ${bdisc}
        Should Be Equal As Strings  ${resp.status_code}  422
        Should Be Equal As Strings  "${resp.json()}"  "${INCORRECT_DISCOUNT_ID}"
        ${cancel}    Random Element     ${cancelReason} 
        ${msg}=  Fakerlibrary.word
        Append To File  ${EXECDIR}/TDD/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
        ${resp}=  Waitlist Action Cancel  ${wid}  ${cancel}  ${msg} 
        Should Be Equal As Strings  ${resp.status_code}  200 

JD-TC- Create Bill -UH8

        [Documentation]   Create Bill with another provider's coupon
        ${data}=  FakerLibrary.Word
        clear_Coupon   ${PUSERNAME177}
        ${resp}=  Encrypted Provider Login  ${PUSERNAME177}  ${PASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
    
        ${desc}=  FakerLibrary.sentence  nb_words=2  variable_nb_words=False
        ${ser_durtn}=   Random Int   min=2   max=10
        ${ser_amount}=   Random Int   min=100   max=1000
        ${ser_amount1}=   Convert To Number   ${ser_amount}
        ${resp}=  Create Service  ${SERVICE1}  ${desc}   ${ser_durtn}   ${status[0]}  ${btype}   ${bool[1]}   ${notifytype[2]}  ${EMPTY}  ${ser_amount1}  ${bool[0]}  ${bool[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${sid}  ${resp.json()}

        ${coupon}=    FakerLibrary.word
        ${desc}=  FakerLibrary.Sentence   nb_words=2
        ${coupon1_amt}=  Random Int   min=10   max=100
        ${coupon1_amt}=   Convert To Number   ${coupon1_amt}
        ${cupn_code}=   FakerLibrary.word
        ${list}=  Create List  1  2  3  4  5  6  7
        ${sTime}=  db.subtract_timezone_time  ${tz}  0  15
        ${eTime}=  add_timezone_time  ${tz}  0  45  
        ${ST_DAY}=  db.get_date_by_timezone  ${tz}
        ${EN_DAY}=  db.add_timezone_date  ${tz}   10
        ${min_bill_amount}=   Random Int   min=10   max=50
        ${max_disc_val}=   Random Int   min=50   max=100
        ${max_prov_use}=   Random Int   min=10   max=20
        ${book_channel}=   Create List   ${bookingChannel[0]}
        ${coupn_based}=  Create List   ${couponBasedOn[0]}
        ${tc}=  FakerLibrary.sentence
        ${services}=   Create list   ${sid}  
        ${resp}=  Create Provider Coupon   ${coupon}  ${desc}  ${cou_amount}  ${calctype[1]}  ${cupn_code}  ${recurringtype[1]}  ${list}  ${sTime}  ${eTime}  ${ST_DAY}  ${EN_DAY}  ${EMPTY}  ${bool[0]}  ${min_bill_amount}  ${max_disc_val}  ${bool[1]}  ${max_prov_use}  ${book_channel}  ${coupn_based}  ${tc}  services=${services}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${couponId11}  ${resp.json()}
        # ${resp}=  Create Coupon  coupon1112  ${data}  20  ${calc_mode[1]}       
        # Should Be Equal As Strings  ${resp.status_code}  200
        # Set Test Variable  ${couponId}  ${resp.json()}
        ${resp}=  ProviderLogout    
        Should Be Equal As Strings  ${resp.status_code}  200
        
        ${resp}=  Encrypted Provider Login  ${PUSERNAME_Z}  ${PASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        
        ${DAY}=  db.add_timezone_date  ${tz}  2  
        Set Suite Variable   ${DAY}  
        ${resp}=  Add To Waitlist  ${cid}  ${sid3}  ${qid1}  ${DAY}  ${cnote}  ${bool[1]}  ${cid}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Suite Variable  ${wid}  ${wid[0]}

        ${resp}=  Get Bill By UUId  ${wid}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${bid}  ${resp.json()['id']}

        # ${coupon}=  Provider Coupons  ${bid}  ${couponId11}

        ${resp}=  Update Bill   ${wid}  ${action[12]}    ${cupn_code}
        Log  ${resp.json()}
        # Should Be Equal As Strings  ${resp.status_code}  422        
        # Should Be Equal As Strings  "${resp.json()}"  "Coupon doesn't targeted to this bill"

        # Should Be Equal As Strings  ${resp.status_code}  409        
        # Should Be Equal As Strings  "${resp.json()}"   "Provider coupon not applicable for this service"
        Should Be Equal As Strings  ${resp.status_code}  422       
        Should Be Equal As Strings  "${resp.json()}"   "Invalid coupon code"

        # Should Be Equal As Strings  "${resp.json()}"  "${INCORRECT_COUPON_ID}"
        ${cancel}    Random Element    ${cancelReason} 
        ${msg}=  Fakerlibrary.word
        Append To File  ${EXECDIR}/TDD/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
        ${resp}=  Waitlist Action Cancel  ${wid}   ${cancel}  ${msg} 
        Should Be Equal As Strings  ${resp.status_code}  200 

*** Comment ***
JD-TC- Create Bill -24

        [Documentation]   Create Bill for service GST Number not updated  
        Comment   formula for total = itemcharge-discount-coupon+GST + servicrcharge-discount-coupon+GST
        clear_location    ${PUSERNAME10}
        clear_service       ${PUSERNAME1}
        clear_Item          ${PUSERNAME1}
        clear_location      ${PUSERNAME1} 
        
        ${notify}    Random Element     ['${bool[1]}','False'] 
        ${description}=  FakerLibrary.sentence  nb_words=2  variable_nb_words=False
        ${resp}=  Encrypted Provider Login  ${PUSERNAME1}  ${PASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME7}
        
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${cid}  ${resp.json()[0]['id']}
        ${DAY}=  db.get_date_by_timezone  ${tz}
        Set Suite Variable  ${DAY}  ${DAY}
        
        ${resp}=  Create Service   ${SERVICE8}     ${description}   ${service_duration[2]}   ${status[0]}  ${btype}   ${bool[1]}   ${notifytype[2]}   0   500.0  ${bool[0]}  ${bool[0]}
         
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${sid7}  ${resp.json()}
        ${list}=  Create List   1  2  3  4  5  6  7
        ${longi}=  db.Get Latitude
        ${latti}=  db.Get Longitude
        ${LsTime}=  add_timezone_time  ${tz}  1  00  
        ${LeTime}=  add_timezone_time  ${tz}  2  00  
        ${address}=  get_address
        Set Suite Variable  ${address}
        ${postcode}=  FakerLibrary.postcode
        ${hr}    Random Element     ['${bool[1]}','False']
        ${parking}    Random Element     ['none','free','street','privatelot','valet','paid']
        ${resp}=  Create Location  san ciro  ${longi}  ${latti}  www.sampleurl.com  ${postcode}  ${address}  ${parking}   ${hr}   Weekly  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${LsTime}  ${LeTime}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${lid}  ${resp.json()}
        ${sTime}=  add_timezone_time  ${tz}  3  30  
        ${eTime}=  add_timezone_time  ${tz}  4  00  
        ${resp}=  Create Queue  ${queue2}  Weekly  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  1  100  ${lid}  ${sid7}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${qid1}  ${resp.json()}
        ${resp}=  Add To Waitlist  ${cid}  ${sid7}  ${qid1}  ${DAY}  ${cnote}  ${bool[1]}  0
         
        Should Be Equal As Strings  ${resp.status_code}  200
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Test Variable  ${wid}  ${wid[0]}
        Log  ${wid}
        Log  ${wid[0]} 
        ${resp}=  Get Bill By UUId  ${wid}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  uuid=${wid}  netTotal=500.0  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  netRate=500.0  billPaymentStatus=${paymentStatus[0]}  totalAmountPaid=0.0  amountDue=500.0  taxableTotal=0.0  totalTaxAmount=0.0
        Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${sid7}
        Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE8} 
        Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
        Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  500.0
        Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}  500.0


JD-TC- Create Bill -25

        [Documentation]   Create Bill for item and service GST Number not updated
        ${description}=  FakerLibrary.sentence  nb_words=2  variable_nb_words=False
        ${data}=  FakerLibrary.Word
        ${notify}    Random Element     ['${bool[1]}','False']
        ${resp}=  Encrypted Provider Login  ${PUSERNAME1}  ${PASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${it_amount4}=   Random Int   min=100   max=500
        ${it_amount4}=   Convert To Number   ${it_amount}
        ${resp}=  Create Item   itemYY  ${data}  ${data}  ${it_amount4}  ${bool[0]}          
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${itemId}  ${resp.json()}
        
        ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME7}
        
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${cid}  ${resp.json()[0]['id']}
        ${resp}=  Create Service  ${SERVICE9}    ${description}   ${service_duration[2]}   ${status[0]}  ${btype}   ${bool[1]}   ${notifytype[2]}  0   500.0  ${bool[0]}  ${bool[0]}
         
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${sid8}  ${resp.json()}
        ${sTime}=  add_timezone_time  ${tz}  0  1
        ${eTime}=  add_timezone_time  ${tz}  5  00  
        ${list}=  Create List   1  2  3  4  5  6  7
        ${resp}=  Create Queue  ${queue3}  Weekly  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  1  100  ${lid}  ${sid8} 
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${qid1}  ${resp.json()}
        ${resp}=  Add To Waitlist  ${cid}  ${sid8}  ${qid1}  ${DAY}  ${cnote}  ${bool[1]}  0
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Test Variable  ${wid}  ${wid[0]}
        ${resp}=  Get Bill By UUId  ${wid}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${item}=  Item Bill  my Item  ${itemId}   1
        ${resp}=  Update Bill   ${wid}  ${action[3]}    ${item}      
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp}=  Get Bill By UUId  ${wid}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  uuid=${wid}  netTotal=1000.0  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  netRate=1000.0  billPaymentStatus=${paymentStatus[0]}  totalAmountPaid=0.0  amountDue=1000.0  taxableTotal=0.0  totalTaxAmount=0.0
        Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${sid8}
        Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE9}
        Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
        Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}   0.0 
        Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  500.0
        Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}  500.0 
        Should Be Equal As Strings  ${resp.json()['items'][0]['itemId']}  ${itemId}  
        Should Be Equal As Strings  ${resp.json()['items'][0]['price']}  500.0 
        Should Be Equal As Strings  ${resp.json()['items'][0]['itemName']}  itemYY 
        Should Be Equal As Strings  ${resp.json()['items'][0]['quantity']}  1.0
