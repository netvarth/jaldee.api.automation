*** Settings ***
Suite Teardown  Delete All Sessions
Test Teardown   Delete All Sessions
Force Tags      JDN
Library         Collections
Library         String
Library         json
Library         FakerLibrary
Library         /ebs/TDD/db.py
Resource        /ebs/TDD/ProviderKeywords.robot
Resource        /ebs/TDD/ConsumerKeywords.robot
Variables       /ebs/TDD/varfiles/providers.py
Variables       /ebs/TDD/varfiles/consumerlist.py 

***Variables***
${SERVICE1}       SERVICE1
${SERVICE2}       SERVICE2
${SERVICE3}       SERVICE3

*** Test Cases ***

JD-TC-EnableJDN-1
	[Documentation]  Enable JDN Percent for a valid provider in billable Domain

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
    ${PUSERNAME_Z}=  Evaluate  ${PUSERNAME}+9563      
    Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${PUSERNAME_Z}${\n}
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

    ${DAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable   ${DAY}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable    ${list}
    ${PUSERPH4}=  Evaluate  ${PUSERNAME}+305
    Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${PUSERPH4}${\n}
    ${PUSERPH5}=  Evaluate  ${PUSERNAME}+306
    Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${PUSERPH5}${\n}
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
    # ${city}=   FakerLibrary.state
    # ${latti}=  get_latitude
    # ${longi}=  get_longitude
    # ${postcode}=  FakerLibrary.postcode
    # ${address}=  get_address
    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    # ${sTime}=  db.get_time_by_timezone  ${tz}
    ${sTime}=  db.get_time_by_timezone  ${tz}
    ${eTime}=  add_timezone_time  ${tz}  0  15  
    ${desc}=   FakerLibrary.sentence
    ${url}=   FakerLibrary.url
    ${parking}   Random Element   ${parkingType}
    ${resp}=  Update Business Profile with schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${bool[1]}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}  ${EMPTY}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
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
    ${disc_max}=   Random Int   min=100   max=500
    ${disc_max}=  Convert To Number   ${disc_max}
    Set Suite Variable   ${disc_max}
    ${d_note}=   FakerLibrary.word
    ${resp}=   Enable JDN for Percent    ${d_note}  ${jdn_disc_percentage[0]}   ${disc_max}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=   Get JDN 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()['discPercentage']}   ${jdn_disc_percentage[0]}
    Should Be Equal As Strings   ${resp.json()['discMax']}          ${disc_max}
    Should Be Equal As Strings   ${resp.json()['status']}           ${Qstate[0]}

JD-TC-EnableJDN-2
	[Documentation]  Enable JDN Percent and check bill

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_Z}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cid}=  get_id  ${CUSERNAME3}
    Set Suite Variable  ${cid}
    ${desc}=  FakerLibrary.sentence
    Set Suite Variable   ${desc}
    ${ser_durtn}=   Random Int   min=2   max=10
    Set Suite Variable   ${ser_durtn}
    ${ser_amount}=   Random Int   min=100   max=1000
    ${ser_amount}=   Convert To Number   ${ser_amount}
    Set Suite Variable   ${ser_amount}
    ${resp}=  Create Service  ${SERVICE1}  ${desc}   ${ser_durtn}   ${status[0]}  ${btype}   ${bool[1]}   ${notifytype[2]}  ${EMPTY}  ${ser_amount}  ${bool[0]}  ${bool[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sid1}  ${resp.json()}
    ${ser_amount1}=   Random Int   min=500   max=1000
    ${ser_amount1}=   Convert To Number   ${ser_amount1}
    Set Suite Variable   ${ser_amount1}
    ${resp}=  Create Service  ${SERVICE2}  ${desc}   ${ser_durtn}   ${status[0]}  ${btype}   ${bool[1]}   ${notifytype[2]}  ${EMPTY}  ${ser_amount1}  ${bool[0]}  ${bool[1]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sid2}  ${resp.json()}
    ${ser_amount2}=   Random Int   min=5000   max=8000
    ${ser_amount2}=   Convert To Number   ${ser_amount2}
    Set Suite Variable   ${ser_amount2}
    ${resp}=  Create Service  ${SERVICE3}  ${desc}   ${ser_durtn}   ${status[0]}  ${btype}   ${bool[1]}   ${notifytype[2]}  ${EMPTY}  ${ser_amount2}  ${bool[0]}  ${bool[1]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sid3}  ${resp.json()}
    
    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${lid}   ${resp.json()[0]['id']}
 
    ${capacity}=   Random Int   min=20   max=100
    ${parallel}=   Random Int   min=1   max=2
    ${sTime}=  add_timezone_time  ${tz}  1  30  
    ${eTime}=  add_timezone_time  ${tz}  3  00  
    ${queue1}=   FakerLibrary.word
    ${resp}=  Create Queue  ${queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${parallel}  ${capacity}  ${lid}  ${sid1}  ${sid2}   ${sid3}
    Log   ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qid1}  ${resp.json()}
    ${c_note}=   FakerLibrary.word
    Set Suite Variable   ${c_note}

    ${resp}=  AddCustomer  ${CUSERNAME3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME3}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${cid}  ${resp.json()[0]['id']}
    ${resp}=  Add To Waitlist  ${cid}  ${sid1}  ${qid1}  ${DAY}  ${c_note}  ${bool[1]}  ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wid[0]}

    ${total}=   Evaluate   ${ser_amount} * ${jdn_disc_percentage[0]}
    ${total}=  Convert To Number   ${total}   2
    ${net_rate}=   Evaluate    ${total} / 100  
    ${net_rate}=  Convert To Number   ${net_rate}   2
    ${amount}=  Set Variable If  ${net_rate} > ${disc_max}   ${disc_max}   ${net_rate}
    ${net_rate1}=   Evaluate   ${ser_amount} - ${amount}
    ${net_rate1}=  Convert To Number   ${net_rate1}     2
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()}
    Set Test Variable  ${bid}  ${resp.json()['id']}
    Verify Response  ${resp}  uuid=${wid}  netTotal=${ser_amount}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  netRate=${net_rate1}  billPaymentStatus=${paymentStatus[0]}  totalAmountPaid=0.0  amountDue=${net_rate1}  taxableTotal=0.0  totalTaxAmount=0.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}       ${sid1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}     ${SERVICE1} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}        1.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}           ${ser_amount}
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}         ${ser_amount}

JD-TC-EnableJDN-3
	[Documentation]  Check if already created bill gets updated when JDN is enabled

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
    ${PUSERNAME_Y}=  Evaluate  ${PUSERNAME}+6530      
    Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${PUSERNAME_Y}${\n}
    ${pkg_id}=   get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${domain}  ${subdomain}  ${PUSERNAME_Y}   ${pkg_id[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAME_Y}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAME_Y}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${PUSERNAME_Y}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_Y}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 
    ${PUSERPH4}=  Evaluate  ${PUSERNAME}+505
    Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${PUSERPH4}${\n}
    ${PUSERPH5}=  Evaluate  ${PUSERNAME}+506
    Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${PUSERPH5}${\n}
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
    # ${city}=   FakerLibrary.state
    # ${latti}=  get_latitude
    # ${longi}=  get_longitude
    # ${postcode}=  FakerLibrary.postcode
    # ${address}=  get_address
    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    # ${sTime}=  db.get_time_by_timezone  ${tz}
    ${sTime}=  db.get_time_by_timezone  ${tz}
    ${eTime}=  add_timezone_time  ${tz}  0  15  
    ${desc}=   FakerLibrary.sentence
    ${url}=   FakerLibrary.url
    ${parking}   Random Element   ${parkingType}
    ${resp}=  Update Business Profile with schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${bool[1]}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}  ${EMPTY}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
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
    sleep   1s
    ${resp}=  Create Service  ${SERVICE1}  ${desc}   ${ser_durtn}   ${status[0]}  ${btype}   ${bool[1]}   ${notifytype[2]}  ${EMPTY}  ${ser_amount}  ${bool[0]}  ${bool[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sid11}  ${resp.json()}
    ${resp}=  Create Service  ${SERVICE2}  ${desc}   ${ser_durtn}   ${status[0]}  ${btype}   ${bool[1]}   ${notifytype[2]}  ${EMPTY}  ${ser_amount1}  ${bool[0]}  ${bool[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sid12}  ${resp.json()}

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${lid11}   ${resp.json()[0]['id']}

    ${capacity}=   Random Int   min=20   max=100
    ${parallel}=   Random Int   min=1   max=2
    ${sTime}=  add_timezone_time  ${tz}  1  30  
    ${eTime}=  add_timezone_time  ${tz}  3  00  
    ${queue1}=   FakerLibrary.word
    ${resp}=  Create Queue  ${queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${parallel}  ${capacity}  ${lid11}  ${sid11}   ${sid12}
    Log   ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qid11}  ${resp.json()}
    ${c_note}=   FakerLibrary.word
    Set Suite Variable   ${c_note}

    ${resp}=  AddCustomer  ${CUSERNAME3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME3}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${cid}  ${resp.json()[0]['id']}
    ${resp}=  Add To Waitlist  ${cid}  ${sid11}  ${qid11}  ${DAY}  ${c_note}  ${bool[1]}  ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${wid1}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid1}  ${wid1[0]}

    ${resp}=  Get Bill By UUId  ${wid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()}
    Set Test Variable  ${bid}  ${resp.json()['id']}
    Verify Response  ${resp}  uuid=${wid1}  netTotal=${ser_amount}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  netRate=${ser_amount}  billPaymentStatus=${paymentStatus[0]}  totalAmountPaid=0.0  amountDue=${ser_amount}  taxableTotal=0.0  totalTaxAmount=0.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}       ${sid11}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}     ${SERVICE1} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}        1.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}           ${ser_amount}
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}         ${ser_amount}

    ${d_note}=   FakerLibrary.word
    ${resp}=   Enable JDN for Percent    ${d_note}  ${jdn_disc_percentage[0]}   ${disc_max}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=   Get JDN 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Bill By UUId  ${wid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()}
    Set Test Variable  ${bid}  ${resp.json()['id']}
    Verify Response  ${resp}  uuid=${wid1}  netTotal=${ser_amount}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  netRate=${ser_amount}  billPaymentStatus=${paymentStatus[0]}  totalAmountPaid=0.0  amountDue=${ser_amount}  taxableTotal=0.0  totalTaxAmount=0.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}       ${sid11}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}     ${SERVICE1} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}        1.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}           ${ser_amount}
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}         ${ser_amount}


JD-TC-EnableJDN-4
	[Documentation]  Check if already created bill gets updated when JDN is enabled and bill is updated

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_Y}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 

    ${reason}=  FakerLibrary.word
    ${service}=  Service Bill  ${reason}  ${sid12}   1 
    ${resp}=  Update Bill  ${wid1}  ${action[0]}  ${service}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 

    ${servicecharge}=   Evaluate   ${ser_amount} + ${ser_amount1}

    ${total}=   Evaluate   ${ser_amount} * ${jdn_disc_percentage[0]}
    ${total}=  Convert To Number   ${total}   2
    ${net_rate1}=   Evaluate    ${total} / 100 
    ${amount1}=  Set Variable If  ${net_rate1} > ${disc_max}   ${disc_max}   ${net_rate1} 
    ${net_rate11}=   Evaluate   ${ser_amount} - ${amount1}
    ${net_rate11}=  Convert To Number   ${net_rate11}     2

    ${total1}=   Evaluate   ${ser_amount1} * ${jdn_disc_percentage[0]}
    ${total1}=  Convert To Number   ${total1}   2
    ${net_rate2}=   Evaluate    ${total1} / 100 
    ${amount2}=  Set Variable If  ${net_rate2} > ${disc_max}   ${disc_max}   ${net_rate2} 
    ${net_rate12}=   Evaluate   ${ser_amount1} - ${amount2}
    ${net_rate12}=  Convert To Number   ${net_rate12}     2
    
    ${net_rate}=   Evaluate   ${net_rate11} + ${net_rate12}
    ${net_rate}=  roundoff    ${net_rate}
    ${resp}=  Get Bill By UUId  ${wid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${bid}  ${resp.json()['id']}
    Verify Response  ${resp}  uuid=${wid1}  netTotal=${servicecharge}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  netRate=${net_rate}  billPaymentStatus=${paymentStatus[0]}  totalAmountPaid=0.0  amountDue=${net_rate}  taxableTotal=0.0  totalTaxAmount=0.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}       ${sid11}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}     ${SERVICE1} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}        1.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}           ${ser_amount}
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}         ${ser_amount}
    Should Be Equal As Strings  ${resp.json()['service'][1]['serviceId']}       ${sid12}
    Should Be Equal As Strings  ${resp.json()['service'][1]['serviceName']}     ${SERVICE2} 
    Should Be Equal As Strings  ${resp.json()['service'][1]['quantity']}        1.0
    Should Be Equal As Strings  ${resp.json()['service'][1]['price']}           ${ser_amount1}
    Should Be Equal As Strings  ${resp.json()['service'][1]['netRate']}         ${ser_amount1}

JD-TC-EnableJDN-5
	[Documentation]  Enable JDN Percent and check bill with GST and the JDN discounted amount less than discount max

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_Z}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200    
    ${GST_num}   ${PAN_num}=  Generate_gst_number  ${Container_id}
    ${resp}=  Update Tax Percentage  ${gstpercentage[1]}   ${GST_num} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Enable Tax
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  AddCustomer  ${CUSERNAME4}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid1}  ${resp.json()}

    # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME4}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${cid1}  ${resp.json()[0]['id']}
    ${resp}=  Add To Waitlist  ${cid1}  ${sid2}  ${qid1}  ${DAY}  ${c_note}  ${bool[1]}  ${cid1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wid[0]}

    ${total}=   Evaluate   ${ser_amount1} * ${jdn_disc_percentage[0]}
    ${total}=   Convert To Number   ${total}    2
    ${net_rate}=   Evaluate    ${total} / 100  
    ${net_rate}=  Convert To Number   ${net_rate}   2
    ${amount}=  Set Variable If  ${net_rate} > ${disc_max}   ${disc_max}   ${net_rate}
    ${net_rate1}=   Evaluate   ${ser_amount1} - ${amount}
    ${net_rate1}=  Convert To Number   ${net_rate1}   2
    ${gst_rate}=   Evaluate   ${net_rate1} * ${gstpercentage[1]}
    ${gst_rate}=   Convert To Number   ${gst_rate}  2
    ${gst_rate1}=   Evaluate    ${gst_rate} / 100 
    ${gst_rate1}=  Convert To Number   ${gst_rate1}    2
    ${final_amount}=   Evaluate   ${net_rate1} + ${gst_rate1}
    ${final_amount}=  Convert To Number   ${final_amount}   2
    ${resp}=  Get Bill By UUId  ${wid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()}
    Set Test Variable  ${bid}  ${resp.json()['id']}
    Verify Response  ${resp}  uuid=${wid}  netTotal=${ser_amount1}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  netRate=${final_amount}  billPaymentStatus=${paymentStatus[0]}  totalAmountPaid=0.0  amountDue=${final_amount}  taxableTotal=${net_rate1}  totalTaxAmount=${gst_rate1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}           ${sid2}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}         ${SERVICE2} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}            1.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}       ${gstpercentage[1]}
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}               ${ser_amount1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}             ${ser_amount1}

JD-TC-EnableJDN-6
	[Documentation]  Enable JDN Percent and check bill with GST and the JDN discounted amount greater than discount max

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_Z}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200    
    ${GST_num}   ${PAN_num}=  Generate_gst_number  ${Container_id}
    ${resp}=  Update Tax Percentage  ${gstpercentage[2]}   ${GST_num} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Enable Tax
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  AddCustomer  ${CUSERNAME5}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid2}  ${resp.json()}

    # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME5}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${cid2}  ${resp.json()[0]['id']}
    ${resp}=  Add To Waitlist  ${cid2}  ${sid3}  ${qid1}  ${DAY}  ${c_note}  ${bool[1]}  ${cid2} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wid[0]}

    ${total}=   Evaluate   ${ser_amount2} * ${jdn_disc_percentage[0]}
    ${total}=   Convert To Number   ${total}    2
    ${net_rate}=   Evaluate    ${total} / 100  
    ${net_rate}=  Convert To Number   ${net_rate}   2
    ${amount}=  Set Variable If  ${net_rate} > ${disc_max}   ${disc_max}   ${net_rate}
    ${net_rate1}=   Evaluate   ${ser_amount2} - ${amount}
    ${net_rate1}=  Convert To Number   ${net_rate1}  2
    ${gst_rate}=   Evaluate   ${net_rate1} * ${gstpercentage[2]}
    ${gst_rate}=   Convert To Number   ${gst_rate}   2
    ${gst_rate1}=   Evaluate    ${gst_rate} / 100 
    ${gst_rate1}=  Convert To Number   ${gst_rate1}   2 
    ${final_amount}=   Evaluate   ${net_rate1} + ${gst_rate1}
    ${final_amount}=  Convert To Number   ${final_amount}   2
    ${resp}=  Get Bill By UUId  ${wid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()}
    Set Test Variable  ${bid}  ${resp.json()['id']}
    Verify Response  ${resp}  uuid=${wid}  netTotal=${ser_amount2}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  netRate=${final_amount}  billPaymentStatus=${paymentStatus[0]}  totalAmountPaid=0.0  amountDue=${final_amount}  taxableTotal=${net_rate1}  totalTaxAmount=${gst_rate1} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}           ${sid3}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}         ${SERVICE3} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}            1.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}       ${gstpercentage[2]}
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}               ${ser_amount2}
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}             ${ser_amount2}

JD-TC-EnableJDN-7
	[Documentation]  Enable JDN for a valid provider in billable Domain without display note

    clear_jdn   ${PUSERNAME_Z}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_Z}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Enable JDN for Percent    ${EMPTY}  ${jdn_disc_percentage[0]}   ${disc_max}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-EnableJDN-8
	[Documentation]  Enable a JDN for a valid provider in Non-billable Domain

    ${domresp}=  Get BusinessDomainsConf
    Log  ${domresp.json()}
    Should Be Equal As Strings  ${domresp.status_code}  200
    Set Suite Variable  ${domresp}

    ${dlen}=  Get Length  ${domresp.json()}
    FOR  ${pos}  IN RANGE  ${dlen}  
        Set Test Variable  ${domain}  ${domresp.json()[${pos}]['domain']}
        ${subdomain}  ${check}=  Get Non Billable Subdomain  ${domain}  ${domresp}  ${pos}  
        Set Test Variable   ${subdomain}
        Exit For Loop IF     '${check}' == '${bool[0]}'

    END
    
    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${PUSERNAME_A}=  Evaluate  ${PUSERNAME}+3338        
    Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${PUSERNAME_A}${\n}
    ${licid}  ${licname}=   get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${domain}  ${subdomain}  ${PUSERNAME_A}   ${licid}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Account Activation  ${PUSERNAME_A}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Account Set Credential  ${PUSERNAME_A}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${PUSERNAME_A}
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_A}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 

    ${PUSERPH4}=  Evaluate  ${PUSERNAME}+666
    Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${PUSERPH4}${\n}
    ${PUSERPH5}=  Evaluate  ${PUSERNAME}+665
    Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${PUSERPH5}${\n}
    ${PUSERMAIL3}=   Set Variable  ${P_Email}${PUSERPH5}.${test_mail}
    ${views}=  Evaluate  random.choice($Views)  random
    ${name1}=  FakerLibrary.name
    ${name2}=  FakerLibrary.name
    ${name3}=  FakerLibrary.name
    ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${PUSERPH4}  ${views}
    ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${PUSERPH5}  ${views}
    ${emails1}=  Emails  ${name3}  Email  ${PUSERMAIL3}  ${views}
    ${bs}=  FakerLibrary.bs
    ${companySuffix}=  FakerLibrary.companySuffix
    # ${city}=   FakerLibrary.state
    # ${latti}=  get_latitude
    # ${longi}=  get_longitude
    # ${postcode}=  FakerLibrary.postcode
    # ${address}=  get_address
    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    # ${sTime}=  db.get_time_by_timezone  ${tz}
    ${sTime}=  db.get_time_by_timezone  ${tz}
    ${eTime}=  add_timezone_time  ${tz}  0  15  
    ${desc}=   FakerLibrary.sentence
    ${url}=   FakerLibrary.url
    ${parking}   Random Element   ${parkingType}
    ${resp}=  Update Business Profile with schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${bool[1]}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}  ${EMPTY}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
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
    ${resp}=  Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[0]}  ${boolean[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${label}=   FakerLibrary.word
    ${d_note}=   FakerLibrary.word  
    ${resp}=   Enable JDN for Label    ${label}   ${d_note}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200   
    ${resp}=   Get JDN 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()['label']}            ${label}
    Should Be Equal As Strings   ${resp.json()['discPercentage']}   0.0
    Should Be Equal As Strings   ${resp.json()['status']}           ${Qstate[0]}

JD-TC-EnableJDN-UH1
	[Documentation]  Enable a JDN label for a valid provider in billable Domain

    clear_jdn   ${PUSERNAME_Z}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_Z}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${label}=   FakerLibrary.word
    ${d_note}=   FakerLibrary.word  
    ${resp}=   Enable JDN for Label    ${label}   ${d_note}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422
    ${JDN_TYPE_INVALID}=   Format String    ${JDN_TYPE_INVALID}    ${jdn_type[0]}
    Should Be Equal As Strings    ${resp.json()}    ${JDN_TYPE_INVALID}

JD-TC-EnableJDN-UH2
	[Documentation]  Enable a JDN label  with empty label

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_A}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Disable JDN
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${d_note}=   FakerLibrary.word
    ${resp}=   Enable JDN for Label    ${EMPTY}   ${d_note}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}    ${JDN_LABEL_NOT_GIVEN}

JD-TC-EnableJDN-UH3
	[Documentation]  Enable already enabled JDN label 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_A}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${label}=   FakerLibrary.word
    ${d_note}=   FakerLibrary.word  
    ${resp}=   Enable JDN for Label    ${label}   ${d_note}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${label}=   FakerLibrary.word
    ${d_note}=   FakerLibrary.word  
    ${resp}=   Enable JDN for Label    ${label}   ${d_note}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}    ${JDN_DISC_ALREADY_ENABLED}

JD-TC-EnableJDN-UH4
	[Documentation]  Enable already enabled JDN percent

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_Z}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${disc_max}=   Random Int   min=100   max=300
    ${disc_max}=  Convert To Number   ${disc_max}
    ${d_note}=   FakerLibrary.word
    ${resp}=   Enable JDN for Percent    ${d_note}  ${jdn_disc_percentage[0]}   ${disc_max}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${disc_max}=   FakerLibrary.Pyfloat  positive=True  left_digits=3  right_digits=1
    ${d_note}=   FakerLibrary.word
    ${resp}=   Enable JDN for Percent    ${d_note}  ${jdn_disc_percentage[0]}   ${disc_max}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}    ${JDN_DISC_ALREADY_ENABLED}

JD-TC-EnableJDN-UH5
	[Documentation]  Enable a JDN percent for a valid provider in Non-billable Domain

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_A}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Disable JDN
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${disc_max}=   Random Int   min=100   max=500
    ${d_note}=   FakerLibrary.word
    ${resp}=   Enable JDN for Percent    ${d_note}  ${jdn_disc_percentage[0]}   ${disc_max}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422
    ${JDN_TYPE_INVALID}=   Format String    ${JDN_TYPE_INVALID}    ${jdn_type[1]}
    Should Be Equal As Strings    ${resp.json()}    ${JDN_TYPE_INVALID}

JD-TC-EnableJDN-UH6
	[Documentation]  Enable a JDN percent without login

    ${disc_max}=   Random Int   min=100   max=500
    ${d_note}=   FakerLibrary.word
    ${resp}=   Enable JDN for Percent    ${d_note}  ${jdn_disc_percentage[0]}   ${disc_max}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    419
    Should Be Equal As Strings    ${resp.json()}    ${SESSION_EXPIRED}

JD-TC-EnableJDN-UH7
	[Documentation]  Enable a JDN label without login

    ${label}=   FakerLibrary.word
    ${d_note}=   FakerLibrary.word  
    ${resp}=   Enable JDN for Label    ${label}   ${d_note}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    419
    Should Be Equal As Strings    ${resp.json()}    ${SESSION_EXPIRED}

JD-TC-EnableJDN-UH8
	[Documentation]  Enable a JDN Percent with invalid discount percent

    clear_jdn   ${PUSERNAME150}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME150}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${disc_max}=   Random Int   min=100   max=500
    ${disc_percent}=   Random Int   min=100   max=500
    ${d_note}=   FakerLibrary.word
    ${resp}=   Enable JDN for Percent    ${d_note}  ${disc_percent}   ${disc_max}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}    ${JDN_PERCENT_INVALID}

JD-TC-EnableJDN-UH9
	[Documentation]  Enable a JDN Percent with invalid discount max

    ${resp}=  Encrypted Provider Login  ${PUSERNAME150}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${disc_max}=   Random Int   min=10   max=90
    ${d_note}=   FakerLibrary.word
    ${resp}=   Enable JDN for Percent    ${d_note}  ${jdn_disc_percentage[0]}   ${disc_max}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422
    ${JDN_AMT_INVALID}=  Format String    ${JDN_AMT_INVALID}    ${jdn_disc_max[0]}
    Should Be Equal As Strings    ${resp.json()}    ${JDN_AMT_INVALID}

JD-TC-EnableJDN-UH10
	[Documentation]  Enable a JDN Percent with invalid discount max

    ${resp}=  Encrypted Provider Login  ${PUSERNAME150}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${disc_max}=   Random Int   min=100   max=190
    ${d_note}=   FakerLibrary.word
    ${resp}=   Enable JDN for Percent    ${d_note}  ${jdn_disc_percentage[1]}   ${disc_max}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422
    ${JDN_AMT_INVALID}=  Format String    ${JDN_AMT_INVALID}    ${jdn_disc_max[1]} 
    Should Be Equal As Strings    ${resp.json()}    ${JDN_AMT_INVALID}

JD-TC-EnableJDN-UH11
	[Documentation]  Enable a JDN Percent with invalid discount max

    ${resp}=  Encrypted Provider Login  ${PUSERNAME150}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${disc_max}=   Random Int   min=200   max=290
    ${d_note}=   FakerLibrary.word
    ${resp}=   Enable JDN for Percent    ${d_note}  ${jdn_disc_percentage[2]}   ${disc_max}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422
    ${JDN_AMT_INVALID}=  Format String    ${JDN_AMT_INVALID}    ${jdn_disc_max[2]} 
    Should Be Equal As Strings    ${resp.json()}    ${JDN_AMT_INVALID}

JD-TC-EnableJDN-UH12
	[Documentation]  Enable a JDN Percent with Empty discount max

    ${resp}=  Encrypted Provider Login  ${PUSERNAME150}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${d_note}=   FakerLibrary.word
    ${resp}=   Enable JDN for Percent    ${d_note}  ${jdn_disc_percentage[0]}   ${EMPTY}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}    ${JDN_DISCOUNT_NOT_GIVEN}

JD-TC-EnableJDN-UH13
	[Documentation]  Enable a JDN Percent with Empty discount percent

    ${resp}=  Encrypted Provider Login  ${PUSERNAME150}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${d_note}=   FakerLibrary.word
    ${resp}=   Enable JDN for Percent    ${d_note}  ${EMPTY}   ${disc_max}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}    ${JDN_PERCENT_INVALID}

JD-TC-EnableJDN-UH14
	[Documentation]  Enable a JDN Percent by consumer login

    ${resp}=  Consumer Login   ${CUSERNAME0}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${disc_max}=   Random Int   min=100   max=500
    ${d_note}=   FakerLibrary.word
    ${resp}=   Enable JDN for Percent    ${d_note}  ${jdn_disc_percentage[0]}   ${disc_max}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    401
    Should Be Equal As Strings    ${resp.json()}    ${LOGIN_NO_ACCESS_FOR_URL} 

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
