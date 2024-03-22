*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        User Waitlist
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/Keywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/SuperAdminKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/musers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/consumermail.py



*** Variables ***

${digits}       0123456789
${ZOOM_url}     https://zoom.us/j/{}?pwd=THVLcTBZa2lESFZQbU9DQTQrWUxWZz09
${self}         0
@{service_duration}   5   20
${parallel}     1
${SERVICE1}   SERVICE1
${SERVICE2}   SERVICE2
${SERVICE3}   SERVICE3
${SERVICE4}   SERVICE4
${SERVICE5}   SERVICE5
${SERVICE6}   SERVICE6
${MAX_SERVICE}      MaxLimitONE
${BRANCH_SERVICE1}   BranchSERVICE1
${BRANCH_SERVICE2}   BranchSERVICE2
${BRANCH_SERVICE3}   BranchSERVICE3
${BRANCH_SERVICE4}   BranchSERVICE4
${BRANCH_SERVICE5}   BranchSERVICE5
${BRANCH_SERVICE6}   BranchSERVICE6
${BRANCH_SERVICE7}   BranchSERVICE7
@{provider_list}
${start}              60 
@{emptylist} 

*** Test Cases ***

JD-TC-Add To Waitlist of User ByConsumer-1
        [Documentation]  Consumer joins waitlist of a valid provider.    
        ${resp}=  Encrypted Provider Login  ${MUSERNAME29}  ${PASSWORD}
        Log   ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200
        Set Test Variable  ${P_Sector}   ${resp.json()['sector']}
        ${p_id}=  get_acc_id  ${MUSERNAME29}
       

        clear_Department    ${MUSERNAME29}
        clear_service       ${MUSERNAME29}
        clear_location      ${MUSERNAME29}

        ${DAY1}=  db.get_date_by_timezone  ${tz}
        Set Suite Variable  ${DAY1}  ${DAY1}
        ${list}=  Create List  1  2  3  4  5  6  7
        ${sTime}=  db.subtract_timezone_time  ${tz}  1  0
        Set Suite Variable  ${BsTime30}  ${sTime}
        ${eTime}=  add_timezone_time  ${tz}  4  00  
        Set Suite Variable  ${BeTime30}  ${eTime}
        Set Suite Variable  ${list}  ${list}
        ${ph1}=  Evaluate  ${PUSERNAME}+1000000000
        ${ph2}=  Evaluate  ${PUSERNAME}+2000000000
        ${views}=  Evaluate  random.choice($Views)  random
        ${name1}=  FakerLibrary.name
        ${name2}=  FakerLibrary.name
        ${name3}=  FakerLibrary.name
        ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
        ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
        ${emails1}=  Emails  ${name3}  Email  ${P_Email}${MUSERNAME29}.${test_mail}  ${views}
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

        #${resp}=  Create Business Profile  ${bs}  ${bs} Desc   ${companySuffix}  ${city}   ${longi}  ${latti}  www.${companySuffix}.com  free  True  Weekly  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}
        #Log   ${resp.content}
        #Should Be Equal As Strings    ${resp.status_code}    200

        ${resp}=  Update Business Profile with schedule  ${bs}  ${bs} Desc   ${companySuffix}  ${city}  ${longi}  ${latti}  www.${companySuffix}.com  free  True  Weekly  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}  ${EMPTY}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep   01s

        ${resp}=  Get Business Profile
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()['baseLocation']['bSchedule']['timespec'][0]['startDate']}  ${DAY1}
        Should Be Equal As Strings  ${resp.json()['baseLocation']['bSchedule']['timespec'][0]['timeSlots'][0]['sTime']}  ${sTime}
        Should Be Equal As Strings  ${resp.json()['baseLocation']['bSchedule']['timespec'][0]['timeSlots'][0]['eTime']}  ${eTime}
        

        ${highest_package}=  get_highest_license_pkg
        Log  ${highest_package}
        Set Suite variable  ${lic2}  ${highest_package[0]}
        ${resp}=   Change License Package  ${highest_package[0]}
        Log   ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}   200

        ${GST_num}  ${pan_num}=   db.Generate_gst_number   ${Container_id}
        ${resp}=  Update Tax Percentage  ${gstpercentage[3]}  ${GST_num} 
        Log   ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}   200
    
        ${resp}=  Enable Tax
        Log   ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}   200

        # ${ifsc_code}=   db.Generate_ifsc_code
        # ${bank_ac}=   db.Generate_random_value  size=11   chars=${digits} 
        # ${bank_name}=  FakerLibrary.company
        # ${name}=  FakerLibrary.name
        # ${branch}=   db.get_place
        # ${resp}=   Update Account Payment Settings   ${bool[0]}  ${bool[0]}  ${bool[1]}  ${MUSERNAME26}   ${pan_num}  ${bank_ac}  ${bank_name}  ${ifsc_code}  ${name}  ${name}  ${branch}  ${businessFilingStatus[1]}  ${accountType[1]}   
        # Log   ${resp.content}
        # Should Be Equal As Strings    ${resp.status_code}   200
        # ${resp}=  payuVerify  ${p_id}
        # Log  ${resp}
        # ${resp}=   Update Account Payment Settings   ${bool[1]}  ${bool[0]}  ${bool[1]}  ${MUSERNAME26}   ${pan_num}  ${bank_ac}  ${bank_name}  ${ifsc_code}  ${name}  ${name}  ${branch}  ${businessFilingStatus[1]}  ${accountType[1]}    
        # Log   ${resp.content}
        # Should Be Equal As Strings    ${resp.status_code}   200
        # ${resp}=  SetMerchantId  ${p_id}  ${merchantid}

        ${resp}=    Update Waitlist Settings  ${calc_mode[0]}  20  ${bool[1]}  ${bool[1]}  ${bool[1]}   ${bool[0]}   ${EMPTY}  
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=  Toggle Department Enable
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
    
        ${dep_name1}=  FakerLibrary.bs
        Set Suite Variable   ${dep_name1}
        ${dep_code1}=   Random Int  min=100   max=999
        Set Suite Variable   ${dep_code1}
        ${dep_desc1}=   FakerLibrary.word  
        Set Suite Variable    ${dep_desc1}
        ${resp}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1}
        Should Be Equal As Strings    ${resp.status_code}    200
        Set Suite Variable  ${dep_id}  ${resp.json()}
    
        ${number}=  Random Int  min=1000  max=2000
        ${PUSERNAME_U1}=  Evaluate  ${PUSERNAME}+${number}
        clear_users  ${PUSERNAME_U1}
        Set Suite Variable  ${PUSERNAME_U1}
        ${firstname}=  FakerLibrary.name
        Set Suite Variable  ${firstname}
        ${lastname}=  FakerLibrary.last_name
        Set Suite Variable  ${lastname}
        ${dob}=  FakerLibrary.Date
        Set Suite Variable  ${dob}
        # ${pin}=  get_pincode
        # Set Suite Variable  ${pin}

        # ${resp}=  Get LocationsByPincode     ${pin}
        FOR    ${i}    IN RANGE    3
                ${pin}=  get_pincode
                ${kwstatus}  ${resp} = 	Run Keyword And Ignore Error  Get LocationsByPincode  ${pin}
                IF    '${kwstatus}' == 'FAIL'
                        Continue For Loop
                ELSE IF    '${kwstatus}' == 'PASS'
                        Exit For Loop
                END
        END
        Log   ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200 
        Set Suite Variable  ${city}   ${resp.json()[0]['PostOffice'][0]['District']}   
        Set Suite Variable  ${state}  ${resp.json()[0]['PostOffice'][0]['State']}      
        Set Suite Variable  ${pin}    ${resp.json()[0]['PostOffice'][0]['Pincode']}    


       ${whpnum}=  Evaluate  ${MUSERNAME29}+336245
       ${tlgnum}=  Evaluate  ${MUSERNAME29}+336345
        
        ${resp}=  Get User
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${iscorp_subdomains}=  get_iscorp_subdomains  1
        Log  ${iscorp_subdomains}
        ${length}=  Get Length  ${iscorp_subdomains}
        FOR  ${i}  IN RANGE  ${length}
            Set Suite Variable  ${domains}  ${iscorp_subdomains[${i}]['domain']}
            Set Suite Variable  ${sub_domains}   ${iscorp_subdomains[${i}]['subdomains']}
            Set Suite Variable  ${sub_domain_id}   ${iscorp_subdomains[${i}]['subdomainId']}
            Exit For Loop IF  '${iscorp_subdomains[${i}]['subdomains']}' == '${P_Sector}'
        END
 
        # ${resp}=  Create User  ${firstname}  ${lastname}  ${address}  ${PUSERNAME_U1}  ${dob}    ${Genderlist[0]}  ${userType[0]}  ${P_Email}${PUSERNAME_U1}.${test_mail}  ${location}  ${state}  ${dep_id}  ${sub_domain_id}
        # Log   ${resp.content}
        # Should Be Equal As Strings  ${resp.status_code}  200
        ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U1}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[0]}  ${PUSERNAME_U1}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${countryCodes[1]}  ${whpnum}  ${countryCodes[1]}  ${tlgnum} 
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${u_id}  ${resp.json()}

        ${resp}=  Get User
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${len}=  Get Length  ${resp.json()}
        Should Be Equal As Integers  ${len}  2
        FOR  ${i}  IN RANGE   ${len}
                IF  '${resp.json()[${i}]['id']}' == '${u_id}' 
                        Set Suite Variable   ${p1_id}   ${resp.json()[${i}]['id']}
                ELSE IF  '${resp.json()[${i}]['id']}' != '${u_id}'
                        Set Suite Variable   ${p0_id}   ${resp.json()[${i}]['id']}
                END
        END
        # Set Suite Variable   ${p1_id}   ${resp.json()[0]['id']}
        # Set Suite Variable   ${p0_id}   ${resp.json()[1]['id']}

        ${DAY1}=  db.get_date_by_timezone  ${tz}
        Set Suite Variable  ${DAY1}
        ${DAY2}=  db.add_timezone_date  ${tz}  10        
        Set Suite Variable  ${DAY2}
        ${list}=  Create List  1  2  3  4  5  6  7
        Set Suite Variable  ${list}
        ${sTime1}=  add_timezone_time  ${tz}  0  15  
        Set Suite Variable   ${sTime1}
        ${eTime1}=  add_timezone_time  ${tz}  2  00  
        Set Suite Variable   ${eTime1}
        # ${lid}=  Create Sample Location
        # Set Suite Variable  ${lid}
        ${resp}=    Get Locations
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable   ${lid}   ${resp.json()[0]['id']}
        ${description}=  FakerLibrary.sentence
        Set Suite Variable  ${description}
        ${dur}=  FakerLibrary.Random Int  min=10  max=20
        Set Suite Variable  ${dur}
        ${amt}=  FakerLibrary.Random Int  min=200  max=500
        Set Suite Variable  ${amt}
        ${totalamt}=  Convert To Number  ${amt}  1
        Set Suite Variable  ${totalamt}
    

        ${resp}=  Create Service For User  ${SERVICE1}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  ${EMPTY}  ${totalamt}  ${bool[0]}  ${bool[0]}  ${dep_id}  ${u_id}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${s_id1}  ${resp.json()}

        ${resp}=  Create Service For User  ${SERVICE2}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  ${EMPTY}  ${totalamt}  ${bool[0]}  ${bool[0]}  ${dep_id}  ${u_id}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${s_id2}  ${resp.json()}

        ${queue_name}=  FakerLibrary.name
        ${resp}=  Create Queue For User  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${lid}  ${u_id}  ${s_id1}  ${s_id2}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${que_id}  ${resp.json()}


        # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME1}
        # Log   ${resp.content}
        # Should Be Equal As Strings  ${resp.status_code}  200
        # Set Suite Variable  ${cid1}  ${resp.json()[0]['id']}

        ${resp}=  ProviderLogout
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=  Consumer Login  ${CUSERNAME1}  ${PASSWORD}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${cid}=  get_id  ${CUSERNAME1}
    
        ${msg}=  FakerLibrary.word
        ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
        ${resp}=  Add To Waitlist Consumer For User  ${p_id}  ${que_id}  ${CUR_DAY}  ${s_id1}  ${msg}  ${bool[0]}  ${p1_id}  ${self}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Suite Variable  ${cwid}  ${wid[0]} 

        ${resp}=  Encrypted Provider Login  ${MUSERNAME29}  ${PASSWORD}
        Log   ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200

        ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME1}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${cid1}  ${resp.json()[0]['id']}

        ${resp}=  Consumer Login  ${CUSERNAME1}  ${PASSWORD}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=  Get consumer Waitlist By Id   ${cwid}  ${p_id}   
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[0]}  paymentStatus=${paymentStatus[0]}  partySize=1  appxWaitingTime=0  waitlistedBy=CONSUMER  personsAhead=0
        Should Be Equal As Strings  ${resp.json()['service']['name']}  ${SERVICE1}
        Should Be Equal As Strings  ${resp.json()['service']['id']}  ${s_id1}
        Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}  ${cid}           
        Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${cid1}  
        Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${que_id}
    

JD-TC-Add To Waitlist of User ByConsumer-2
	[Documentation]  Provider removes consumer waitlisted for a service and consumer joins the waitlist of the same service and another service of same queue

        ${resp}=  Encrypted Provider Login  ${MUSERNAME29}  ${PASSWORD}
        Log   ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200
        ${p_id}=  get_acc_id  ${MUSERNAME29}

        ${cancl_reasn}=   FakerLibrary.sentence
        ${resp}=  Waitlist Action Cancel  ${cwid}  ${waitlist_cancl_reasn[3]}  ${cancl_reasn}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=  Consumer Login  ${CUSERNAME1}  ${PASSWORD}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${cid}=  get_id  ${CUSERNAME1}
    
        ${msg}=  FakerLibrary.word
        # ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
        ${DAY4}=  db.add_timezone_date  ${tz}  2  
        ${resp}=  Add To Waitlist Consumer For User  ${p_id}  ${que_id}  ${DAY4}  ${s_id1}  ${msg}  ${bool[0]}  ${p1_id}  ${self}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Suite Variable  ${cwid1}  ${wid[0]} 


        ${msg}=  FakerLibrary.word
        ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
        ${resp}=  Add To Waitlist Consumer For User  ${p_id}  ${que_id}  ${DAY4}  ${s_id2}  ${msg}  ${bool[0]}  ${p1_id}  ${self}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Suite Variable  ${cwid2}  ${wid[0]} 


        ${resp}=  Get consumer Waitlist By Id   ${cwid1}  ${p_id}   
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  date=${DAY4}  waitlistStatus=${wl_status[0]}  paymentStatus=${paymentStatus[0]}  partySize=1  waitlistedBy=CONSUMER  personsAhead=0
        Should Be Equal As Strings  ${resp.json()['service']['name']}  ${SERVICE1}
        Should Be Equal As Strings  ${resp.json()['service']['id']}  ${s_id1}
        Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}  ${cid}           
        Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${cid1}  
        Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${que_id}
    

        ${resp}=  Get consumer Waitlist By Id   ${cwid2}  ${p_id}   
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  date=${DAY4}  waitlistStatus=${wl_status[0]}  paymentStatus=${paymentStatus[0]}  partySize=1  waitlistedBy=CONSUMER  personsAhead=1
        Should Be Equal As Strings  ${resp.json()['service']['name']}  ${SERVICE2}
        Should Be Equal As Strings  ${resp.json()['service']['id']}  ${s_id2}
        Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}  ${cid}           
        Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${cid1}  
        Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${que_id}
    
        

JD-TC-Add To Waitlist of User ByConsumer-3
	[Documentation]  consumer cancels the waitlist then consumer again joins in the waitlist for same service 
        
        ${resp}=  Consumer Login  ${CUSERNAME1}  ${PASSWORD}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${cid}=  get_id  ${CUSERNAME1}
        ${p_id}=  get_acc_id  ${MUSERNAME29}

        ${resp}=  Cancel Waitlist  ${cwid1}  ${p_id} 
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep   02s
    
        ${msg}=  FakerLibrary.word
        # ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
        ${DAY4}=  db.add_timezone_date  ${tz}  2  
        ${resp}=  Add To Waitlist Consumer For User  ${p_id}  ${que_id}  ${DAY4}  ${s_id1}  ${msg}  ${bool[0]}  ${p1_id}  ${self}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Suite Variable  ${cwid3}  ${wid[0]} 


        ${resp}=  Get consumer Waitlist By Id   ${cwid3}  ${p_id}   
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  date=${DAY4}  waitlistStatus=${wl_status[0]}  paymentStatus=${paymentStatus[0]}  partySize=1  waitlistedBy=CONSUMER  personsAhead=1
        Should Be Equal As Strings  ${resp.json()['service']['name']}  ${SERVICE1}
        Should Be Equal As Strings  ${resp.json()['service']['id']}  ${s_id1}
        Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}  ${cid}           
        Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${cid1}  
        Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${que_id}
    
        ${resp}=  Cancel Waitlist  ${cwid3}  ${p_id} 
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep   02s

        ${resp}=  Cancel Waitlist  ${cwid2}  ${p_id} 
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep   02s


JD-TC-Add To Waitlist of User ByConsumer-4
	[Documentation]  A Consumer Added To Waitlist for same service in diffrent queues of Different USERS

        ${resp}=  Encrypted Provider Login  ${MUSERNAME29}  ${PASSWORD}
        Log   ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200
        ${p_id}=  get_acc_id  ${MUSERNAME29}


        ${number1}=  Random Int  min=1000  max=2000
        ${PUSERNAME_U2}=  Evaluate  ${PUSERNAME}+${number1}
        clear_users  ${PUSERNAME_U2}
        Set Suite Variable  ${PUSERNAME_U2}
        ${firstname2}=  FakerLibrary.name
        Set Suite Variable  ${firstname2}
        ${lastname2}=  FakerLibrary.last_name
        Set Suite Variable  ${lastname2}
        
        # ${resp}=  Create User  ${firstname2}  ${lastname2}  ${address}  ${PUSERNAME_U2}  ${dob}    ${Genderlist[0]}  ${userType[0]}  ${P_Email}${PUSERNAME_U2}.${test_mail}  ${location}  ${state}  ${dep_id}  ${sub_domain_id}
        # Log   ${resp.content}
        # Should Be Equal As Strings  ${resp.status_code}  200
        ${resp}=  Create User  ${firstname2}  ${lastname2}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U2}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[0]}  ${PUSERNAME_U2}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${countryCodes[1]}  ${PUSERNAME_U2}  ${countryCodes[1]}  ${PUSERNAME_U2} 
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${u_id2}  ${resp.json()}

        ${resp}=  Get User
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        # Set Suite Variable   ${p2_id}   ${resp.json()[0]['id']}
        ${len}=  Get Length  ${resp.json()}
        Should Be Equal As Integers  ${len}  3
        FOR  ${i}  IN RANGE   ${len}
                IF  '${resp.json()[${i}]['id']}' == '${u_id2}' 
                        Set Suite Variable   ${p2_id}   ${resp.json()[${i}]['id']}
                ELSE IF  '${resp.json()[${i}]['id']}' == '${u_id}'
                        Set Suite Variable   ${p1_id}   ${resp.json()[${i}]['id']}
                ELSE IF  '${resp.json()[${i}]['id']}' not in ['${u_id}','${u_id2}']
                        Set Suite Variable   ${p0_id}   ${resp.json()[${i}]['id']}
                END
        END
        
        ${resp}=  Create Service For User  ${SERVICE1}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  ${EMPTY}  ${totalamt}  ${bool[0]}  ${bool[0]}  ${dep_id}  ${u_id2}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${s_id3}  ${resp.json()}

        ${resp}=  Create Service For User  ${SERVICE2}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  ${EMPTY}  ${totalamt}  ${bool[0]}  ${bool[0]}  ${dep_id}  ${u_id2}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${s_id4}  ${resp.json()}

        ${queue_name2}=  FakerLibrary.name
        ${resp}=  Create Queue For User  ${queue_name2}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${lid}  ${u_id2}  ${s_id3}  ${s_id4}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${que_id2}  ${resp.json()}
        
        ${resp}=  Consumer Login  ${CUSERNAME1}  ${PASSWORD}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${cid}=  get_id  ${CUSERNAME1}
    
        ${msg}=  FakerLibrary.word
        # ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
        ${DAY1}=  db.add_timezone_date  ${tz}  1  
        ${resp}=  Add To Waitlist Consumer For User  ${p_id}  ${que_id}  ${DAY1}  ${s_id1}  ${msg}  ${bool[0]}  ${p1_id}  ${self}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Suite Variable  ${cwid1}  ${wid[0]} 

        ${resp}=  Add To Waitlist Consumer For User  ${p_id}  ${que_id2}  ${DAY1}  ${s_id3}  ${msg}  ${bool[0]}  ${p2_id}  ${self}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Suite Variable  ${cwid2}  ${wid[0]} 

        ${resp}=  Get consumer Waitlist By Id   ${cwid1}  ${p_id}   
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[0]}  paymentStatus=${paymentStatus[0]}  partySize=1  waitlistedBy=CONSUMER  personsAhead=0
        Should Be Equal As Strings  ${resp.json()['service']['name']}  ${SERVICE1}
        Should Be Equal As Strings  ${resp.json()['service']['id']}  ${s_id1}
        Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}  ${cid}           
        Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${cid1}  
        Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${que_id}

        ${resp}=  Get consumer Waitlist By Id   ${cwid2}  ${p_id}   
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[0]}  paymentStatus=${paymentStatus[0]}  partySize=1  waitlistedBy=CONSUMER  personsAhead=0
        Should Be Equal As Strings  ${resp.json()['service']['name']}  ${SERVICE1}
        Should Be Equal As Strings  ${resp.json()['service']['id']}  ${s_id3}
        Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}  ${cid}           
        Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${cid1}  
        Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${que_id2}
    
        ${resp}=  Cancel Waitlist  ${cwid1}  ${p_id} 
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep   02s

        ${resp}=  Cancel Waitlist  ${cwid2}  ${p_id} 
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep   02s

JD-TC-Add To Waitlist of User ByConsumer-5
	[Documentation]  Consumer Added To Waitlist for diffrent services of diffrent Queue 

        ${resp}=  Encrypted Provider Login  ${MUSERNAME29}  ${PASSWORD}
        Log   ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200
        ${p_id}=  get_acc_id  ${MUSERNAME29}


        # ${number1}=  Random Int  min=1000  max=2000
        # ${PUSERNAME_U2}=  Evaluate  ${PUSERNAME}+${number1}
        # clear_users  ${PUSERNAME_U2}
        # Set Suite Variable  ${PUSERNAME_U2}
        # ${firstname2}=  FakerLibrary.name
        # Set Suite Variable  ${firstname2}
        # ${lastname2}=  FakerLibrary.last_name
        # Set Suite Variable  ${lastname2}
        
        ${resp}=  Create Service For User  ${SERVICE5}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  ${EMPTY}  ${totalamt}  ${bool[0]}  ${bool[0]}  ${dep_id}  ${u_id}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${s_id5}  ${resp.json()}

        ${resp}=  Create Service For User  ${SERVICE6}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  ${EMPTY}  ${totalamt}  ${bool[0]}  ${bool[0]}  ${dep_id}  ${u_id}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${s_id6}  ${resp.json()}

        ${queue_name3}=  FakerLibrary.name
        ${resp}=  Create Queue For User  ${queue_name3}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${lid}  ${u_id}  ${s_id5}  ${s_id6}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${que_id3}  ${resp.json()}
        
        ${resp}=  Consumer Login  ${CUSERNAME1}  ${PASSWORD}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${cid}=  get_id  ${CUSERNAME1}
    
        ${msg}=  FakerLibrary.word
        # ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
        ${DAY1}=  db.add_timezone_date  ${tz}  1  
        ${resp}=  Add To Waitlist Consumer For User  ${p_id}  ${que_id}  ${DAY1}  ${s_id1}  ${msg}  ${bool[0]}  ${p1_id}  ${self}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Suite Variable  ${cwid1}  ${wid[0]} 

        ${resp}=  Add To Waitlist Consumer For User  ${p_id}  ${que_id3}  ${DAY1}  ${s_id5}  ${msg}  ${bool[0]}  ${p1_id}  ${self}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Suite Variable  ${cwid2}  ${wid[0]} 

        ${resp}=  Get consumer Waitlist By Id   ${cwid1}  ${p_id}   
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[0]}  paymentStatus=${paymentStatus[0]}  partySize=1  waitlistedBy=CONSUMER  personsAhead=0
        Should Be Equal As Strings  ${resp.json()['service']['name']}  ${SERVICE1}
        Should Be Equal As Strings  ${resp.json()['service']['id']}  ${s_id1}
        Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}  ${cid}           
        Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${cid1}  
        Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${que_id}

        ${resp}=  Get consumer Waitlist By Id   ${cwid2}  ${p_id}   
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[0]}  paymentStatus=${paymentStatus[0]}  partySize=1  waitlistedBy=CONSUMER  personsAhead=0
        Should Be Equal As Strings  ${resp.json()['service']['name']}  ${SERVICE5}
        Should Be Equal As Strings  ${resp.json()['service']['id']}  ${s_id5}
        Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}  ${cid}           
        Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${cid1}  
        Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${que_id3}
    
        ${resp}=  Cancel Waitlist  ${cwid1}  ${p_id} 
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep   02s

        ${resp}=  Cancel Waitlist  ${cwid2}  ${p_id} 
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep   02s

JD-TC-Add To Waitlist of User ByConsumer-6
        [Documentation]  Add Consumer To future day waitlist

        ${resp}=  Consumer Login  ${CUSERNAME1}  ${PASSWORD}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${cid}=  get_id  ${CUSERNAME1}
        ${p_id}=  get_acc_id  ${MUSERNAME29}
    
        ${msg}=  FakerLibrary.word
        ${FUTURE_DAY}=  db.add_timezone_date  ${tz}  3  
        ${resp}=  Add To Waitlist Consumer For User  ${p_id}  ${que_id}  ${FUTURE_DAY}  ${s_id1}  ${msg}  ${bool[0]}  ${p1_id}  ${self}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Suite Variable  ${cwid1}  ${wid[0]} 

        ${resp}=  Get consumer Waitlist By Id   ${cwid1}  ${p_id}   
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  date=${FUTURE_DAY}  waitlistStatus=${wl_status[0]}  paymentStatus=${paymentStatus[0]}  partySize=1  waitlistedBy=CONSUMER  personsAhead=0
        Should Be Equal As Strings  ${resp.json()['service']['name']}  ${SERVICE1}
        Should Be Equal As Strings  ${resp.json()['service']['id']}  ${s_id1}
        Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}  ${cid}           
        Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${cid1}  
        Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${que_id}

        ${resp}=  Cancel Waitlist  ${cwid1}  ${p_id} 
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep   02s


JD-TC-Add To Waitlist of User ByConsumer-7
        [Documentation]  Add  Consumer To waitlist for another service in same queue
       
        ${resp}=  Consumer Login  ${CUSERNAME1}  ${PASSWORD}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${cid}=  get_id  ${CUSERNAME1}
        ${p_id}=  get_acc_id  ${MUSERNAME29}

        ${msg}=  FakerLibrary.word
        # ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
        ${DAY1}=  db.add_timezone_date  ${tz}  1  
        ${resp}=  Add To Waitlist Consumer For User  ${p_id}  ${que_id}  ${DAY1}  ${s_id1}  ${msg}  ${bool[0]}  ${p1_id}  ${self}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Suite Variable  ${cwid1}  ${wid[0]} 

        ${resp}=  Add To Waitlist Consumer For User  ${p_id}  ${que_id}  ${DAY1}  ${s_id2}  ${msg}  ${bool[0]}  ${p1_id}  ${self}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Suite Variable  ${cwid2}  ${wid[0]} 


        ${resp}=  Get consumer Waitlist By Id   ${cwid1}  ${p_id}   
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[0]}  paymentStatus=${paymentStatus[0]}  partySize=1  waitlistedBy=CONSUMER  personsAhead=0
        Should Be Equal As Strings  ${resp.json()['service']['name']}  ${SERVICE1}
        Should Be Equal As Strings  ${resp.json()['service']['id']}  ${s_id1}
        Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}  ${cid}           
        Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${cid1}  
        Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${que_id}

        ${resp}=  Get consumer Waitlist By Id   ${cwid2}  ${p_id}   
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[0]}  paymentStatus=${paymentStatus[0]}  partySize=1  waitlistedBy=CONSUMER  personsAhead=1
        Should Be Equal As Strings  ${resp.json()['service']['name']}  ${SERVICE2}
        Should Be Equal As Strings  ${resp.json()['service']['id']}  ${s_id2}
        Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}  ${cid}           
        Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${cid1}  
        Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${que_id}
    
        ${resp}=  Cancel Waitlist  ${cwid1}  ${p_id} 
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep   02s

        ${resp}=  Cancel Waitlist  ${cwid2}  ${p_id} 
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep   02s


JD-TC-Add To Waitlist of User ByConsumer-8
	[Documentation]  A Consumer Added To FUTURE Waitlist for same service in diffrent queues of Different USERS

        ${resp}=  Consumer Login  ${CUSERNAME1}  ${PASSWORD}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${cid}=  get_id  ${CUSERNAME1}
        ${p_id}=  get_acc_id  ${MUSERNAME29}
    
        ${msg}=  FakerLibrary.word
        ${FUTURE_DAY}=  db.add_timezone_date  ${tz}  3  
        ${resp}=  Add To Waitlist Consumer For User  ${p_id}  ${que_id}  ${FUTURE_DAY}  ${s_id1}  ${msg}  ${bool[0]}  ${p1_id}  ${self}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Suite Variable  ${cwid1}  ${wid[0]} 

        ${resp}=  Add To Waitlist Consumer For User  ${p_id}  ${que_id2}  ${FUTURE_DAY}  ${s_id3}  ${msg}  ${bool[0]}  ${p2_id}  ${self}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Suite Variable  ${cwid2}  ${wid[0]} 


        ${resp}=  Get consumer Waitlist By Id   ${cwid1}  ${p_id}   
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  date=${FUTURE_DAY}  waitlistStatus=${wl_status[0]}  paymentStatus=${paymentStatus[0]}  partySize=1  waitlistedBy=CONSUMER  personsAhead=0
        Should Be Equal As Strings  ${resp.json()['service']['name']}  ${SERVICE1}
        Should Be Equal As Strings  ${resp.json()['service']['id']}  ${s_id1}
        Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}  ${cid}           
        Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${cid1}  
        Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${que_id}

        ${resp}=  Get consumer Waitlist By Id   ${cwid2}  ${p_id}   
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  date=${FUTURE_DAY}  waitlistStatus=${wl_status[0]}  paymentStatus=${paymentStatus[0]}  partySize=1  waitlistedBy=CONSUMER  personsAhead=0
        Should Be Equal As Strings  ${resp.json()['service']['name']}  ${SERVICE1}
        Should Be Equal As Strings  ${resp.json()['service']['id']}  ${s_id3}
        Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}  ${cid}           
        Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${cid1}  
        Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${que_id2}
    
        ${resp}=  Cancel Waitlist  ${cwid1}  ${p_id} 
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep   02s

        ${resp}=  Cancel Waitlist  ${cwid2}  ${p_id} 
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep   02s



JD-TC-Add To Waitlist of User ByConsumer-9
	[Documentation]  A Consumer Added To FUTURE Waitlist for Different service in diffrent queues of Different USERS

        ${resp}=  Consumer Login  ${CUSERNAME1}  ${PASSWORD}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${cid}=  get_id  ${CUSERNAME1}
        ${p_id}=  get_acc_id  ${MUSERNAME29}
    
        ${msg}=  FakerLibrary.word
        ${FUTURE_DAY}=  db.add_timezone_date  ${tz}  3  
        ${resp}=  Add To Waitlist Consumer For User  ${p_id}  ${que_id}  ${FUTURE_DAY}  ${s_id1}  ${msg}  ${bool[0]}  ${p1_id}  ${self}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Suite Variable  ${cwid1}  ${wid[0]} 

        ${resp}=  Add To Waitlist Consumer For User  ${p_id}  ${que_id2}  ${FUTURE_DAY}  ${s_id4}  ${msg}  ${bool[0]}  ${p2_id}  ${self}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Suite Variable  ${cwid2}  ${wid[0]} 


        ${resp}=  Get consumer Waitlist By Id   ${cwid1}  ${p_id}   
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  date=${FUTURE_DAY}  waitlistStatus=${wl_status[0]}  paymentStatus=${paymentStatus[0]}  partySize=1  waitlistedBy=CONSUMER  personsAhead=0
        Should Be Equal As Strings  ${resp.json()['service']['name']}  ${SERVICE1}
        Should Be Equal As Strings  ${resp.json()['service']['id']}  ${s_id1}
        Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}  ${cid}           
        Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${cid1}  
        Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${que_id}

        ${resp}=  Get consumer Waitlist By Id   ${cwid2}  ${p_id}   
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  date=${FUTURE_DAY}  waitlistStatus=${wl_status[0]}  paymentStatus=${paymentStatus[0]}  partySize=1  waitlistedBy=CONSUMER  personsAhead=0
        Should Be Equal As Strings  ${resp.json()['service']['name']}  ${SERVICE2}
        Should Be Equal As Strings  ${resp.json()['service']['id']}  ${s_id4}
        Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}  ${cid}           
        Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${cid1}  
        Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${que_id2}
    
        ${resp}=  Cancel Waitlist  ${cwid1}  ${p_id} 
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep   02s

        ${resp}=  Cancel Waitlist  ${cwid2}  ${p_id} 
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep   02s



JD-TC-Add To Waitlist of User ByConsumer-10
        [Documentation]  in current day waitlist, add Family Member
        ${resp}=  Consumer Login  ${CUSERNAME1}  ${PASSWORD}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${cid}=  get_id  ${CUSERNAME1}
        ${p_id}=  get_acc_id  ${MUSERNAME29}

        ${C_fname}=  FakerLibrary.name
        Set Suite Variable   ${C_fname}
        ${C_lname}=  FakerLibrary.last_name
        Set Suite Variable   ${C_lname}
        ${C_dob}=  FakerLibrary.Date
        Set Suite Variable   ${C_dob}
        ${C_gender}    Random Element    ${Genderlist}
        Set Suite Variable   ${C_gender}
        ${resp}=  AddFamilyMember   ${C_fname}  ${C_lname}  ${C_dob}  ${C_gender}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200  
        Set Suite Variable  ${cidfor}   ${resp.json()}
    
        ${msg}=  FakerLibrary.word
        ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
        ${resp}=  Add To Waitlist Consumer For User  ${p_id}  ${que_id}  ${CUR_DAY}  ${s_id1}  ${msg}  ${bool[0]}  ${p1_id}  ${cidfor}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Suite Variable  ${cwid1}  ${wid[0]} 

        ${resp}=  Add To Waitlist Consumer For User  ${p_id}  ${que_id}  ${CUR_DAY}  ${s_id1}  ${msg}  ${bool[0]}  ${p1_id}  ${self}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Suite Variable  ${cwid2}  ${wid[0]} 


        ${resp}=  Get consumer Waitlist By Id   ${cwid1}  ${p_id}   
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[0]}  paymentStatus=${paymentStatus[0]}  partySize=1  waitlistedBy=CONSUMER  personsAhead=0
        Should Be Equal As Strings  ${resp.json()['service']['name']}  ${SERVICE1}
        Should Be Equal As Strings  ${resp.json()['service']['id']}  ${s_id1}
        Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}  ${cid}           
        Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['jaldeeFamilyMemberId']}  ${cidfor}  
        Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${que_id}
        Set Test Variable  ${cfid}   ${resp.json()['waitlistingFor'][0]['id']}



        ${resp}=  Get consumer Waitlist By Id   ${cwid2}  ${p_id}   
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[0]}  paymentStatus=${paymentStatus[0]}  partySize=1  waitlistedBy=CONSUMER  personsAhead=1
        Should Be Equal As Strings  ${resp.json()['service']['name']}  ${SERVICE1}
        Should Be Equal As Strings  ${resp.json()['service']['id']}  ${s_id1}
        Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}  ${cid}           
        Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${cid1}  
        Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${que_id}
    
        ${resp}=  Cancel Waitlist  ${cwid1}  ${p_id} 
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep   02s

        ${resp}=  Cancel Waitlist  ${cwid2}  ${p_id} 
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep   02s

        ${resp}=  Encrypted Provider Login  ${MUSERNAME29}  ${PASSWORD}
        Log   ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200
        ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME1}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${cid}  ${resp.json()[1]['id']}
        ${resp}=  ListFamilyMemberByProvider  ${cid}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response List  ${resp}  0  id=${cfid}
        Should Be Equal As Strings  ${resp.json()[0]['firstName']}  ${C_fname}
        Should Be Equal As Strings  ${resp.json()[0]['lastName']}  ${C_lname}
        Should Be Equal As Strings  ${resp.json()[0]['dob']}  ${C_dob}
        Should Be Equal As Strings  ${resp.json()[0]['gender']}  ${C_gender}


JD-TC-Add To Waitlist of User ByConsumer-11
        [Documentation]  in Future waitlist, add family member

        ${resp}=  Consumer Login  ${CUSERNAME1}  ${PASSWORD}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${cid}=  get_id  ${CUSERNAME1}
        ${p_id}=  get_acc_id  ${MUSERNAME29}

    
        ${msg}=  FakerLibrary.word
        ${FUTURE_DAY}=  db.add_timezone_date  ${tz}  3  
        ${resp}=  Add To Waitlist Consumer For User  ${p_id}  ${que_id}  ${FUTURE_DAY}  ${s_id1}  ${msg}  ${bool[0]}  ${p1_id}  ${cidfor}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Suite Variable  ${cwid1}  ${wid[0]} 

        ${resp}=  Add To Waitlist Consumer For User  ${p_id}  ${que_id}  ${FUTURE_DAY}  ${s_id1}  ${msg}  ${bool[0]}  ${p1_id}  ${self}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Suite Variable  ${cwid2}  ${wid[0]} 


        ${resp}=  Get consumer Waitlist By Id   ${cwid1}  ${p_id}   
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  date=${FUTURE_DAY}  waitlistStatus=${wl_status[0]}  paymentStatus=${paymentStatus[0]}  partySize=1  waitlistedBy=CONSUMER  personsAhead=0
        Should Be Equal As Strings  ${resp.json()['service']['name']}  ${SERVICE1}
        Should Be Equal As Strings  ${resp.json()['service']['id']}  ${s_id1}
        Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}  ${cid}           
        Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['jaldeeFamilyMemberId']}  ${cidfor}  
        Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${que_id}
        Set Test Variable  ${cfid1}   ${resp.json()['waitlistingFor'][0]['id']}

        ${resp}=  Get consumer Waitlist By Id   ${cwid2}  ${p_id}   
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  date=${FUTURE_DAY}  waitlistStatus=${wl_status[0]}  paymentStatus=${paymentStatus[0]}  partySize=1  waitlistedBy=CONSUMER  personsAhead=1
        Should Be Equal As Strings  ${resp.json()['service']['name']}  ${SERVICE1}
        Should Be Equal As Strings  ${resp.json()['service']['id']}  ${s_id1}
        Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}  ${cid}           
        Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${cid1}  
        Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${que_id}
    
        ${resp}=  Cancel Waitlist  ${cwid1}  ${p_id} 
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep   02s

        ${resp}=  Cancel Waitlist  ${cwid2}  ${p_id} 
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep   02s

        ${resp}=  Encrypted Provider Login  ${MUSERNAME29}  ${PASSWORD}
        Log   ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200
        ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME1}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${cid}  ${resp.json()[1]['id']}
        ${resp}=  ListFamilyMemberByProvider  ${cid}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response List  ${resp}  0  id=${cfid1}
        Should Be Equal As Strings  ${resp.json()[0]['firstName']}  ${C_fname}
        Should Be Equal As Strings  ${resp.json()[0]['lastName']}  ${C_lname}
        Should Be Equal As Strings  ${resp.json()[0]['dob']}  ${C_dob}
        Should Be Equal As Strings  ${resp.json()[0]['gender']}  ${C_gender}



JD-TC-Add To Waitlist of User ByConsumer-12
        [Documentation]  same family member add to waitlist  diffrent service  same queue

        ${resp}=  Consumer Login  ${CUSERNAME3}  ${PASSWORD}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${cid}=  get_id  ${CUSERNAME3}
        ${p_id}=  get_acc_id  ${MUSERNAME29}
    
        ${C_fname1}=  FakerLibrary.name
        Set Suite Variable   ${C_fname1}
        ${C_lname1}=  FakerLibrary.last_name
        Set Suite Variable   ${C_lname1}
        ${C_dob1}=  FakerLibrary.Date
        Set Suite Variable   ${C_dob1}
        ${C_gender1}    Random Element    ${Genderlist}
        Set Suite Variable   ${C_gender1}
        ${resp}=  AddFamilyMember   ${C_fname1}  ${C_lname1}  ${C_dob1}  ${C_gender1}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200  
        Set Suite Variable  ${cidfor1}   ${resp.json()}

        ${msg}=  FakerLibrary.word
        # ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
        ${DAY1}=  db.add_timezone_date  ${tz}  1  
        ${resp}=  Add To Waitlist Consumer For User  ${p_id}  ${que_id}  ${DAY1}  ${s_id1}  ${msg}  ${bool[0]}  ${p1_id}  ${cidfor1}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Suite Variable  ${cwid1}  ${wid[0]} 

        ${resp}=  Add To Waitlist Consumer For User  ${p_id}  ${que_id}  ${DAY1}  ${s_id2}  ${msg}  ${bool[0]}  ${p1_id}  ${cidfor1}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Suite Variable  ${cwid2}  ${wid[0]} 

        ${resp}=  Encrypted Provider Login  ${MUSERNAME29}  ${PASSWORD}
        Log   ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200

        ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME3}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${cid2}  ${resp.json()[0]['id']}

        ${resp}=  Consumer Login  ${CUSERNAME3}  ${PASSWORD}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=  Get consumer Waitlist By Id   ${cwid1}  ${p_id}   
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[0]}  paymentStatus=${paymentStatus[0]}  partySize=1  waitlistedBy=CONSUMER  personsAhead=0
        Should Be Equal As Strings  ${resp.json()['service']['name']}  ${SERVICE1}
        Should Be Equal As Strings  ${resp.json()['service']['id']}  ${s_id1}
        Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}  ${cid}           
        Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['jaldeeFamilyMemberId']}  ${cidfor1}  
        Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${que_id}
        Set Test Variable  ${cfid2}   ${resp.json()['waitlistingFor'][0]['id']}

        ${resp}=  Get consumer Waitlist By Id   ${cwid2}  ${p_id}   
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[0]}  paymentStatus=${paymentStatus[0]}  partySize=1  waitlistedBy=CONSUMER  personsAhead=1
        Should Be Equal As Strings  ${resp.json()['service']['name']}  ${SERVICE2}
        Should Be Equal As Strings  ${resp.json()['service']['id']}  ${s_id2}
        Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}  ${cid}           
        Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['jaldeeFamilyMemberId']}  ${cidfor1}  
        Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${que_id}
    
        ${resp}=  Cancel Waitlist  ${cwid1}  ${p_id} 
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep   02s

        ${resp}=  Cancel Waitlist  ${cwid2}  ${p_id} 
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep   02s

        ${resp}=  Encrypted Provider Login  ${MUSERNAME29}  ${PASSWORD}
        Log   ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200
        ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME3}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${cid}  ${resp.json()[1]['id']}
        ${resp}=  ListFamilyMemberByProvider  ${cid}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response List  ${resp}  0  id=${cfid2}
        Should Be Equal As Strings  ${resp.json()[0]['firstName']}  ${C_fname1}
        Should Be Equal As Strings  ${resp.json()[0]['lastName']}  ${C_lname1}
        Should Be Equal As Strings  ${resp.json()[0]['dob']}  ${C_dob1}
        Should Be Equal As Strings  ${resp.json()[0]['gender']}  ${C_gender1}



JD-TC-Add To Waitlist of User ByConsumer-13
        [Documentation]  same family member add to waitlist,  same service,  diffrent queue, Different users
        ${resp}=  Consumer Login  ${CUSERNAME3}  ${PASSWORD}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${cid}=  get_id  ${CUSERNAME3}
        ${p_id}=  get_acc_id  ${MUSERNAME29}
    
        ${msg}=  FakerLibrary.word
        # ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
        ${DAY1}=  db.add_timezone_date  ${tz}  1  
        ${resp}=  Add To Waitlist Consumer For User  ${p_id}  ${que_id}  ${DAY1}  ${s_id1}  ${msg}  ${bool[0]}  ${p1_id}  ${cidfor1}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Suite Variable  ${cwid1}  ${wid[0]} 

        ${resp}=  Add To Waitlist Consumer For User  ${p_id}  ${que_id2}  ${DAY1}  ${s_id3}  ${msg}  ${bool[0]}  ${p2_id}  ${cidfor1}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Suite Variable  ${cwid2}  ${wid[0]} 

        ${resp}=  Get consumer Waitlist By Id   ${cwid1}  ${p_id}   
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[0]}  paymentStatus=${paymentStatus[0]}  partySize=1  waitlistedBy=CONSUMER  personsAhead=0
        Should Be Equal As Strings  ${resp.json()['service']['name']}  ${SERVICE1}
        Should Be Equal As Strings  ${resp.json()['service']['id']}  ${s_id1}
        Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}  ${cid}           
        Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['jaldeeFamilyMemberId']}  ${cidfor1}  
        Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${que_id}
        Set Test Variable  ${cfid3}   ${resp.json()['waitlistingFor'][0]['id']}

        ${resp}=  Get consumer Waitlist By Id   ${cwid2}  ${p_id}   
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[0]}  paymentStatus=${paymentStatus[0]}  partySize=1  waitlistedBy=CONSUMER  personsAhead=0
        Should Be Equal As Strings  ${resp.json()['service']['name']}  ${SERVICE1}
        Should Be Equal As Strings  ${resp.json()['service']['id']}  ${s_id3}
        Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}  ${cid}           
        Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['jaldeeFamilyMemberId']}  ${cidfor1}  
        Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${que_id2}
    
        ${resp}=  Cancel Waitlist  ${cwid1}  ${p_id} 
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep   02s

        ${resp}=  Cancel Waitlist  ${cwid2}  ${p_id} 
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep   02s

        ${resp}=  Encrypted Provider Login  ${MUSERNAME29}  ${PASSWORD}
        Log   ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200
        ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME3}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${cid}  ${resp.json()[1]['id']}
        ${resp}=  ListFamilyMemberByProvider  ${cid}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response List  ${resp}  0  id=${cfid3}
        Should Be Equal As Strings  ${resp.json()[0]['firstName']}  ${C_fname1}
        Should Be Equal As Strings  ${resp.json()[0]['lastName']}  ${C_lname1}
        Should Be Equal As Strings  ${resp.json()[0]['dob']}  ${C_dob1}
        Should Be Equal As Strings  ${resp.json()[0]['gender']}  ${C_gender1}


JD-TC-Add To Waitlist of User ByConsumer-14
        [Documentation]  From future waitlist Consumer remove himself and again add for same service
        ${resp}=  Consumer Login  ${CUSERNAME1}  ${PASSWORD}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${cid}=  get_id  ${CUSERNAME1}
        ${p_id}=  get_acc_id  ${MUSERNAME29}
    
        ${msg}=  FakerLibrary.word
        # ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
        ${FUTURE_DAY}=  db.add_timezone_date  ${tz}  3  
        ${resp}=  Add To Waitlist Consumer For User  ${p_id}  ${que_id}  ${FUTURE_DAY}  ${s_id1}  ${msg}  ${bool[0]}  ${p1_id}  ${self}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Suite Variable  ${cwid1}  ${wid[0]}

        ${resp}=  Get consumer Waitlist By Id   ${cwid1}  ${p_id}   
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  date=${FUTURE_DAY}  waitlistStatus=${wl_status[0]}  paymentStatus=${paymentStatus[0]}  partySize=1  waitlistedBy=CONSUMER  personsAhead=0
        Should Be Equal As Strings  ${resp.json()['service']['name']}  ${SERVICE1}
        Should Be Equal As Strings  ${resp.json()['service']['id']}  ${s_id1}
        Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}  ${cid}           
        Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${cid1}  
        Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${que_id} 


        ${resp}=  Cancel Waitlist  ${cwid1}  ${p_id}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=  Add To Waitlist Consumer For User  ${p_id}  ${que_id}  ${FUTURE_DAY}  ${s_id1}  ${msg}  ${bool[0]}  ${p1_id}  ${self}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Suite Variable  ${cwid2}  ${wid[0]} 

        ${resp}=  Get consumer Waitlist By Id   ${cwid2}  ${p_id}   
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  date=${FUTURE_DAY}  waitlistStatus=${wl_status[0]}  paymentStatus=${paymentStatus[0]}  partySize=1  waitlistedBy=CONSUMER  personsAhead=0
        Should Be Equal As Strings  ${resp.json()['service']['name']}  ${SERVICE1}
        Should Be Equal As Strings  ${resp.json()['service']['id']}  ${s_id1}
        Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}  ${cid}           
        Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${cid1}  
        Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${que_id}


        ${resp}=  Get consumer Waitlist By Id   ${cwid1}  ${p_id}   
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  date=${FUTURE_DAY}  waitlistStatus=${wl_status[4]}  paymentStatus=${paymentStatus[0]}  partySize=1  waitlistedBy=CONSUMER
        Should Be Equal As Strings  ${resp.json()['service']['name']}  ${SERVICE1}
        Should Be Equal As Strings  ${resp.json()['service']['id']}  ${s_id1}
        Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}  ${cid}           
        Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${cid1}  
        Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${que_id}


        ${resp}=  Cancel Waitlist  ${cwid2}  ${p_id} 
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep   02s


JD-TC-Add To Waitlist of User ByConsumer-15
        [Documentation]  Consumer future waitlist removed by provider and Consumer again add to same service
        ${resp}=  Consumer Login  ${CUSERNAME1}  ${PASSWORD}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${cid}=  get_id  ${CUSERNAME1}
        ${p_id}=  get_acc_id  ${MUSERNAME29}
    
        ${msg}=  FakerLibrary.word
        ${FUTURE_DAY}=  db.add_timezone_date  ${tz}  4  
        ${resp}=  Add To Waitlist Consumer For User  ${p_id}  ${que_id}  ${FUTURE_DAY}  ${s_id1}  ${msg}  ${bool[0]}  ${p1_id}  ${self}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Suite Variable  ${cwid1}  ${wid[0]} 


        ${resp}=  Get consumer Waitlist By Id   ${cwid1}  ${p_id}   
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  date=${FUTURE_DAY}  waitlistStatus=${wl_status[0]}  paymentStatus=${paymentStatus[0]}  partySize=1  waitlistedBy=CONSUMER  personsAhead=0
        Should Be Equal As Strings  ${resp.json()['service']['name']}  ${SERVICE1}
        Should Be Equal As Strings  ${resp.json()['service']['id']}  ${s_id1}
        Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}  ${cid}           
        Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${cid1}  
        Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${que_id}


        ${resp}=  Encrypted Provider Login  ${MUSERNAME29}  ${PASSWORD}
        Log   ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200

        ${msg}=  Fakerlibrary.word
        ${resp}=  Waitlist Action Cancel  ${cwid1}  ${waitlist_cancl_reasn[4]}   ${msg}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
    
        ${resp}=  ProviderLogout
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=  Consumer Login  ${CUSERNAME1}  ${PASSWORD}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=  Add To Waitlist Consumer For User  ${p_id}  ${que_id}  ${FUTURE_DAY}  ${s_id1}  ${msg}  ${bool[0]}  ${p1_id}  ${self}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Suite Variable  ${cwid2}  ${wid[0]} 


        ${resp}=  Get consumer Waitlist By Id   ${cwid2}  ${p_id}   
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  date=${FUTURE_DAY}  waitlistStatus=${wl_status[0]}  paymentStatus=${paymentStatus[0]}  partySize=1  waitlistedBy=CONSUMER  personsAhead=0
        Should Be Equal As Strings  ${resp.json()['service']['name']}  ${SERVICE1}
        Should Be Equal As Strings  ${resp.json()['service']['id']}  ${s_id1}
        Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}  ${cid}           
        Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${cid1}  
        Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${que_id}

        ${resp}=  Get consumer Waitlist By Id   ${cwid1}  ${p_id}   
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  date=${FUTURE_DAY}  waitlistStatus=${wl_status[4]}  paymentStatus=${paymentStatus[0]}  partySize=1  waitlistedBy=CONSUMER
        Should Be Equal As Strings  ${resp.json()['service']['name']}  ${SERVICE1}
        Should Be Equal As Strings  ${resp.json()['service']['id']}  ${s_id1}
        Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}  ${cid}           
        Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${cid1}  
        Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${que_id}

        ${resp}=  Cancel Waitlist  ${cwid2}  ${p_id} 
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep   02s


JD-TC-Add To Waitlist of User ByConsumer-UH1
	[Documentation]  Add To Waitlist By Consumer for the Same Services Two Times
        ${resp}=  Consumer Login  ${CUSERNAME4}  ${PASSWORD}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${cid}=  get_id  ${CUSERNAME4}
        ${p_id}=  get_acc_id  ${MUSERNAME29}
    
        ${msg}=  FakerLibrary.word
        # ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
        ${DAY1}=  db.add_timezone_date  ${tz}  1  
        # SELF
        ${resp}=  Add To Waitlist Consumer For User  ${p_id}  ${que_id}  ${DAY1}  ${s_id1}  ${msg}  ${bool[0]}  ${p1_id}  ${self}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Suite Variable  ${cwid1}  ${wid[0]} 

        ${resp}=  Encrypted Provider Login  ${MUSERNAME29}  ${PASSWORD}
        Log   ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200

        ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME4}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${cid3}  ${resp.json()[0]['id']}

        ${resp}=  Consumer Login  ${CUSERNAME4}  ${PASSWORD}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200


        ${resp}=  Get consumer Waitlist By Id   ${cwid1}  ${p_id}   
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[0]}  paymentStatus=${paymentStatus[0]}  partySize=1  waitlistedBy=CONSUMER  personsAhead=0
        Should Be Equal As Strings  ${resp.json()['service']['name']}  ${SERVICE1}
        Should Be Equal As Strings  ${resp.json()['service']['id']}  ${s_id1}
        Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}  ${cid}           
        Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${cid3}  
        Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${que_id}


        ${resp}=  Add To Waitlist Consumer For User  ${p_id}  ${que_id}  ${DAY1}  ${s_id1}  ${msg}  ${bool[0]}  ${p1_id}  ${self}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  422
        Should Be Equal As Strings  "${resp.json()}"   "${WAITLIST_CUSTOMER_ALREADY_IN}" 

        # FAMILY MEMBER
        ${firstname1}=  FakerLibrary.first_name
        ${lastname1}=  FakerLibrary.last_name
        ${dob1}=  FakerLibrary.Date
        ${gender1}    Random Element    ${Genderlist}
        ${resp}=  AddFamilyMember  ${firstname1}  ${lastname1}  ${dob1}  ${gender1}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${mem_id}  ${resp.json()}

        ${resp}=  Add To Waitlist Consumer For User  ${p_id}  ${que_id}  ${DAY1}  ${s_id1}  ${msg}  ${bool[0]}  ${p1_id}  ${mem_id}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Suite Variable  ${cwid2}  ${wid[0]} 

        ${resp}=  Get consumer Waitlist By Id   ${cwid2}  ${p_id}   
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[0]}  paymentStatus=${paymentStatus[0]}  partySize=1  waitlistedBy=CONSUMER  personsAhead=1
        Should Be Equal As Strings  ${resp.json()['service']['name']}  ${SERVICE1}
        Should Be Equal As Strings  ${resp.json()['service']['id']}  ${s_id1}
        Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}  ${cid}           
        Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['jaldeeFamilyMemberId']}  ${mem_id}  
        Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${que_id}
        Set Test Variable  ${cfid4}   ${resp.json()['waitlistingFor'][0]['id']}


        ${resp}=  Add To Waitlist Consumer For User  ${p_id}  ${que_id}  ${DAY1}  ${s_id1}  ${msg}  ${bool[0]}  ${p1_id}  ${mem_id}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  422
        Should Be Equal As Strings  "${resp.json()}"   "${WAITLIST_CUSTOMER_ALREADY_IN}" 


        ${resp}=  Cancel Waitlist  ${cwid1}  ${p_id} 
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep   02s

        ${resp}=  Cancel Waitlist  ${cwid2}  ${p_id} 
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep   02s

        ${resp}=  Encrypted Provider Login  ${MUSERNAME29}  ${PASSWORD}
        Log   ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200
        ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME4}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${cid}  ${resp.json()[1]['id']}
        ${resp}=  ListFamilyMemberByProvider  ${cid}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response List  ${resp}  0  id=${cfid4}
        Should Be Equal As Strings  ${resp.json()[0]['firstName']}  ${firstname1}
        Should Be Equal As Strings  ${resp.json()[0]['lastName']}  ${lastname1}
        Should Be Equal As Strings  ${resp.json()[0]['dob']}  ${dob1}
        Should Be Equal As Strings  ${resp.json()[0]['gender']}  ${gender1}

JD-TC-Add To Waitlist of User ByConsumer-UH2
        [Documentation]  Reaches waitlist maximum capacity and check
        ${resp}=  Encrypted Provider Login  ${MUSERNAME29}  ${PASSWORD}
        Log   ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200
        ${p_id}=  get_acc_id  ${MUSERNAME29}
        
        ${resp}=  Create Service For User  ${MAX_SERVICE}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  ${EMPTY}  ${totalamt}  ${bool[0]}  ${bool[0]}  ${dep_id}  ${u_id}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${MAX_sid}  ${resp.json()}


        ${MAX_QUEUE}=  FakerLibrary.name
        ${resp}=  Create Queue For User  ${MAX_QUEUE}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  1  ${lid}  ${u_id}  ${MAX_sid}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${MAX_qid}  ${resp.json()}
        

        ${resp}=  Consumer Login  ${CUSERNAME1}  ${PASSWORD}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${cid}=  get_id  ${CUSERNAME1}
    
        ${msg}=  FakerLibrary.word
        # ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
        ${DAY1}=  db.add_timezone_date  ${tz}  1  
        ${resp}=  Add To Waitlist Consumer For User  ${p_id}  ${MAX_qid}  ${DAY1}  ${MAX_sid}  ${msg}  ${bool[0]}  ${p1_id}  ${self}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Suite Variable  ${cwid1}  ${wid[0]} 

        ${resp}=  Get consumer Waitlist By Id   ${cwid1}  ${p_id}   
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[0]}  paymentStatus=${paymentStatus[0]}  partySize=1  waitlistedBy=CONSUMER  personsAhead=0
        Should Be Equal As Strings  ${resp.json()['service']['name']}  ${MAX_SERVICE}
        Should Be Equal As Strings  ${resp.json()['service']['id']}  ${MAX_sid}
        Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}  ${cid}           
        Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${cid1}  
        Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${MAX_qid}

        ${resp}=  Add To Waitlist Consumer For User  ${p_id}  ${MAX_qid}  ${DAY1}  ${MAX_sid}  ${msg}  ${bool[0]}  ${p1_id}  ${self}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  422   
        Should Be Equal As Strings  "${resp.json()}"  "${WATLIST_MAX_LIMIT_REACHED}"

        ${resp}=  Cancel Waitlist  ${cwid1}  ${p_id} 
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep   02s
    
       
JD-TC-Add To Waitlist of User ByConsumer-UH3
	[Documentation]  Add To Waitlist By Consumer, when Queue Disabled  
        ${resp}=  Encrypted Provider Login  ${MUSERNAME29}  ${PASSWORD}
        Log   ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200
        ${p_id}=  get_acc_id  ${MUSERNAME29}
        
        
        ${resp}=  Disable Queue  ${MAX_qid}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep   02s

        ${resp}=  ProviderLogout
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200


        ${resp}=  Consumer Login  ${CUSERNAME1}  ${PASSWORD}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${cid}=  get_id  ${CUSERNAME1}
    
        ${msg}=  FakerLibrary.word
        # ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
        ${DAY1}=  db.add_timezone_date  ${tz}  1  
        ${resp}=  Add To Waitlist Consumer For User  ${p_id}  ${MAX_qid}  ${DAY1}  ${MAX_sid}  ${msg}  ${bool[0]}  ${p1_id}  ${self}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  422
        Should Be Equal As Strings  "${resp.json()}"   "${QUEUE_DISABLED}" 
    
        Comment  AGAIN ENABLE QUEUE
        ${resp}=  Encrypted Provider Login  ${MUSERNAME29}  ${PASSWORD}
        Log   ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200

        ${resp}=  Enable Queue  ${MAX_qid}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep   02s

        ${resp}=  Consumer Login  ${CUSERNAME1}  ${PASSWORD}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${cid}=  get_id  ${CUSERNAME1}
    
        ${msg}=  FakerLibrary.word
        # ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
        ${DAY1}=  db.add_timezone_date  ${tz}  1  
        ${resp}=  Add To Waitlist Consumer For User  ${p_id}  ${MAX_qid}  ${DAY1}  ${MAX_sid}  ${msg}  ${bool[0]}  ${p1_id}  ${self}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Suite Variable  ${cwid1}  ${wid[0]} 

        ${resp}=  Get consumer Waitlist By Id   ${cwid1}  ${p_id}   
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[0]}  paymentStatus=${paymentStatus[0]}  partySize=1  waitlistedBy=CONSUMER  personsAhead=0
        Should Be Equal As Strings  ${resp.json()['service']['name']}  ${MAX_SERVICE}
        Should Be Equal As Strings  ${resp.json()['service']['id']}  ${MAX_sid}
        Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}  ${cid}           
        Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${cid1}  
        Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${MAX_qid}

        ${resp}=  Cancel Waitlist  ${cwid1}  ${p_id} 
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep   02s

JD-TC-Add To Waitlist of User ByConsumer-UH4
	[Documentation]  Add To Waitlist By Consumer ,provider disable online Checkin  
        ${resp}=  Encrypted Provider Login  ${MUSERNAME29}  ${PASSWORD}
        Log   ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200
        ${p_id}=  get_acc_id  ${MUSERNAME29}
        
        ${resp}=  Disable Online Checkin
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep   02s

        ${resp}=  ProviderLogout
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=  Consumer Login  ${CUSERNAME1}  ${PASSWORD}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${cid}=  get_id  ${CUSERNAME1}
    
        ${msg}=  FakerLibrary.word
        ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
        ${resp}=  Add To Waitlist Consumer For User  ${p_id}  ${MAX_qid}  ${CUR_DAY}  ${MAX_sid}  ${msg}  ${bool[0]}  ${p1_id}  ${self}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  422
        Should Be Equal As Strings  "${resp.json()}"   "${ONLINE_CHECKIN_OFF}" 
    
        Comment  AGAIN ENABLE ONLINE_CHECKIN
        ${resp}=  Encrypted Provider Login  ${MUSERNAME29}  ${PASSWORD}
        Log   ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200

        ${resp}=  Enable Online Checkin                                              
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep   02s

        ${resp}=  Consumer Login  ${CUSERNAME1}  ${PASSWORD}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${cid}=  get_id  ${CUSERNAME1}
    
        ${msg}=  FakerLibrary.word
        ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
        ${resp}=  Add To Waitlist Consumer For User  ${p_id}  ${MAX_qid}  ${CUR_DAY}  ${MAX_sid}  ${msg}  ${bool[0]}  ${p1_id}  ${self}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Suite Variable  ${cwid1}  ${wid[0]} 

        ${resp}=  Get consumer Waitlist By Id   ${cwid1}  ${p_id}   
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[0]}  paymentStatus=${paymentStatus[0]}  partySize=1  waitlistedBy=CONSUMER  personsAhead=0
        Should Be Equal As Strings  ${resp.json()['service']['name']}  ${MAX_SERVICE}
        Should Be Equal As Strings  ${resp.json()['service']['id']}  ${MAX_sid}
        Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}  ${cid}           
        Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${cid1}  
        Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${MAX_qid}
    
        ${resp}=  Cancel Waitlist  ${cwid1}  ${p_id} 
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep   02s
    

JD-TC-Add To Waitlist of User ByConsumer-UH5 
    [Documentation]  Add To Waitlist By Consumer ,provider  disable Waitlist
        ${resp}=  Encrypted Provider Login  ${MUSERNAME29}  ${PASSWORD}
        Log   ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200
        ${p_id}=  get_acc_id  ${MUSERNAME29}
        
        ${resp}=  Disable Waitlist
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep   02s

        ${resp}=  View Waitlist Settings
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=  ProviderLogout
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=  Consumer Login  ${CUSERNAME1}  ${PASSWORD}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${cid}=  get_id  ${CUSERNAME1}
    
        ${msg}=  FakerLibrary.word
        # ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
        ${DAY1}=  db.add_timezone_date  ${tz}  1  
        ${resp}=  Add To Waitlist Consumer For User  ${p_id}  ${MAX_qid}  ${DAY1}  ${MAX_sid}  ${msg}  ${bool[0]}  ${p1_id}  ${self}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  422
        Should Be Equal As Strings  "${resp.json()}"   "${WAITLIST_NOT_ENABLED}" 
    
        Comment  AGAIN ENABLE WAITLIST
        ${resp}=  Encrypted Provider Login  ${MUSERNAME29}  ${PASSWORD}
        Log   ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200

        ${resp}=  Enable Waitlist                                              
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep   02s

        ${resp}=  Consumer Login  ${CUSERNAME1}  ${PASSWORD}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${cid}=  get_id  ${CUSERNAME1}
    
        ${msg}=  FakerLibrary.word
        # ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
        ${DAY1}=  db.add_timezone_date  ${tz}  1  
        ${resp}=  Add To Waitlist Consumer For User  ${p_id}  ${MAX_qid}  ${DAY1}  ${MAX_sid}  ${msg}  ${bool[0]}  ${p1_id}  ${self}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Suite Variable  ${cwid1}  ${wid[0]} 

        ${resp}=  Get consumer Waitlist By Id   ${cwid1}  ${p_id}   
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[0]}  paymentStatus=${paymentStatus[0]}  partySize=1  waitlistedBy=CONSUMER  personsAhead=0
        Should Be Equal As Strings  ${resp.json()['service']['name']}  ${MAX_SERVICE}
        Should Be Equal As Strings  ${resp.json()['service']['id']}  ${MAX_sid}
        Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}  ${cid}           
        Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${cid1}  
        Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${MAX_qid}

        ${resp}=  Cancel Waitlist  ${cwid1}  ${p_id} 
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep   02s
    
JD-TC-Add To Waitlist of User ByConsumer-UH6
	[Documentation]  Add To Waitlist By Consumer ,provider Disable Future Checkin
        ${resp}=  Encrypted Provider Login  ${MUSERNAME29}  ${PASSWORD}
        Log   ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200
        ${p_id}=  get_acc_id  ${MUSERNAME29}
        
        ${resp}=  Disable Future Checkin
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep   02s

        ${resp}=  ProviderLogout
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=  Consumer Login  ${CUSERNAME1}  ${PASSWORD}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${cid}=  get_id  ${CUSERNAME1}
    
        ${msg}=  FakerLibrary.word
        ${FUTURE_DAY}=  db.add_timezone_date  ${tz}  3  
        ${resp}=  Add To Waitlist Consumer For User  ${p_id}  ${MAX_qid}  ${FUTURE_DAY}  ${MAX_sid}  ${msg}  ${bool[0]}  ${p1_id}  ${self}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  422
        Should Be Equal As Strings  "${resp.json()}"   "${FUTURE_CHECKIN_DISABLED}"
    
        Comment  AGAIN ENABLE FUTURE_CHECKIN
        ${resp}=  Encrypted Provider Login  ${MUSERNAME29}  ${PASSWORD}
        Log   ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200

        ${resp}=  Enable Future Checkin                                              
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep   02s

        ${resp}=  Consumer Login  ${CUSERNAME1}  ${PASSWORD}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${cid}=  get_id  ${CUSERNAME1}
    
        ${msg}=  FakerLibrary.word
        ${FUTURE_DAY}=  db.get_date_by_timezone  ${tz}
        ${resp}=  Add To Waitlist Consumer For User  ${p_id}  ${MAX_qid}  ${FUTURE_DAY}  ${MAX_sid}  ${msg}  ${bool[0]}  ${p1_id}  ${self}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Suite Variable  ${cwid1}  ${wid[0]} 

        ${resp}=  Get consumer Waitlist By Id   ${cwid1}  ${p_id}   
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  date=${FUTURE_DAY}  waitlistStatus=${wl_status[0]}  paymentStatus=${paymentStatus[0]}  partySize=1  waitlistedBy=CONSUMER  personsAhead=0
        Should Be Equal As Strings  ${resp.json()['service']['name']}  ${MAX_SERVICE}
        Should Be Equal As Strings  ${resp.json()['service']['id']}  ${MAX_sid}
        Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}  ${cid}           
        Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${cid1}  
        Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${MAX_qid}

    
        ${resp}=  Cancel Waitlist  ${cwid1}  ${p_id} 
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep   02s



JD-TC-Add To Waitlist of User ByConsumer-UH7
	[Documentation]  Add To Waitlist By Consumer ,service and queue are diffrent
        ${resp}=  Consumer Login  ${CUSERNAME1}  ${PASSWORD}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${cid}=  get_id  ${CUSERNAME1}
        ${p_id}=  get_acc_id  ${MUSERNAME29}
        ${msg}=  FakerLibrary.word
        ${FUTURE_DAY}=  db.add_timezone_date  ${tz}  3  
        ${resp}=  Add To Waitlist Consumer For User  ${p_id}  ${MAX_qid}  ${FUTURE_DAY}  ${s_id1}  ${msg}  ${bool[0]}  ${p1_id}  ${self}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  422
        Should Be Equal As Strings  "${resp.json()}"   "${SERVICE_NOT_AVAILABLE}"
    

JD-TC-Add To Waitlist of User ByConsumer-UH8
	[Documentation]  Add To Waitlist By Consumer ,provider in holiday
        ${resp}=  Encrypted Provider Login  ${MUSERNAME29}  ${PASSWORD}
        Log   ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200
        ${p_id}=  get_acc_id  ${MUSERNAME29}
        
        
        # ${holidayname}=   FakerLibrary.word
        # ${resp}=  Create Holiday  ${FUTURE_DAY}  ${holidayname}  ${sTime1}  ${eTime1}
        # Log   ${resp.content}
        # Should Be Equal As Strings  ${resp.status_code}  200
        # Set Test Variable  ${hId}  ${resp.json()}
        ${FUTURE_DAY}=  db.add_timezone_date  ${tz}  5  
        ${desc}=    FakerLibrary.name
        ${list}=  Create List   1  2  3  4  5  6  7
        ${resp}=  Create Holiday   ${recurringtype[1]}  ${list}  ${FUTURE_DAY}  ${FUTURE_DAY}  ${EMPTY}  ${sTime1}  ${eTime1}  ${desc}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${hId}    ${resp.json()['holidayId']}

        sleep   02s

        ${resp}=  ProviderLogout
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=  Consumer Login  ${CUSERNAME1}  ${PASSWORD}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${cid}=  get_id  ${CUSERNAME1}
    
        ${msg}=  FakerLibrary.word
        ${resp}=  Add To Waitlist Consumer For User  ${p_id}  ${MAX_qid}  ${FUTURE_DAY}  ${MAX_sid}  ${msg}  ${bool[0]}  ${p1_id}  ${self}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  422
        Should Be Equal As Strings  "${resp.json()}"   "${HOLIDAY_NON_WORKING_DAY}" 
    
        Comment  DELETE HOLIDAY
        ${resp}=  Encrypted Provider Login  ${MUSERNAME29}  ${PASSWORD}
        Log   ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200

        ${resp}=   Delete Holiday  ${hId}                                              
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep   02s

        ${resp}=  Consumer Login  ${CUSERNAME1}  ${PASSWORD}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${cid}=  get_id  ${CUSERNAME1}
    
        ${msg}=  FakerLibrary.word
        ${FUTURE_DAY}=  db.get_date_by_timezone  ${tz}
        ${resp}=  Add To Waitlist Consumer For User  ${p_id}  ${MAX_qid}  ${FUTURE_DAY}  ${MAX_sid}  ${msg}  ${bool[0]}  ${p1_id}  ${self}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Suite Variable  ${cwid1}  ${wid[0]} 

        ${resp}=  Get consumer Waitlist By Id   ${cwid1}  ${p_id}   
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  date=${FUTURE_DAY}  waitlistStatus=${wl_status[0]}  paymentStatus=${paymentStatus[0]}  partySize=1  waitlistedBy=CONSUMER  personsAhead=0
        Should Be Equal As Strings  ${resp.json()['service']['name']}  ${MAX_SERVICE}
        Should Be Equal As Strings  ${resp.json()['service']['id']}  ${MAX_sid}
        Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}  ${cid}           
        Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${cid1}  
        Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${MAX_qid}

        ${resp}=  Cancel Waitlist  ${cwid1}  ${p_id} 
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep   02s
   
JD-TC-Add To Waitlist of User ByConsumer-UH9
	[Documentation]  Add To Waitlist By Consumer, service DISABLED 
        ${resp}=  Encrypted Provider Login  ${MUSERNAME29}  ${PASSWORD}
        Log   ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200
        ${p_id}=  get_acc_id  ${MUSERNAME29}
        
        ${resp}=  Disable service   ${MAX_sid}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep   02s

        ${resp}=  ProviderLogout
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=  Consumer Login  ${CUSERNAME1}  ${PASSWORD}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${cid}=  get_id  ${CUSERNAME1}
        
        ${FUTURE_DAY}=  db.add_timezone_date  ${tz}  5  
        ${msg}=  FakerLibrary.word
        ${resp}=  Add To Waitlist Consumer For User  ${p_id}  ${MAX_qid}  ${FUTURE_DAY}  ${MAX_sid}  ${msg}  ${bool[0]}  ${p1_id}  ${self}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  422
        Should Be Equal As Strings  "${resp.json()}"   "${INVALID_SERVICE}"
    
        Comment  AGAIN ENABLE SERVICE
        ${resp}=  Encrypted Provider Login  ${MUSERNAME29}  ${PASSWORD}
        Log   ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200

        ${resp}=  Enable service  ${MAX_sid}                                              
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep   02s

        ${resp}=  Consumer Login  ${CUSERNAME1}  ${PASSWORD}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${cid}=  get_id  ${CUSERNAME1}
    
        ${msg}=  FakerLibrary.word
        ${FUTURE_DAY}=  db.get_date_by_timezone  ${tz}
        ${resp}=  Add To Waitlist Consumer For User  ${p_id}  ${MAX_qid}  ${FUTURE_DAY}  ${MAX_sid}  ${msg}  ${bool[0]}  ${p1_id}  ${self}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Suite Variable  ${cwid1}  ${wid[0]} 

        ${resp}=  Get consumer Waitlist By Id   ${cwid1}  ${p_id}   
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  date=${FUTURE_DAY}  waitlistStatus=${wl_status[0]}  paymentStatus=${paymentStatus[0]}  partySize=1  waitlistedBy=CONSUMER  personsAhead=0
        Should Be Equal As Strings  ${resp.json()['service']['name']}  ${MAX_SERVICE}
        Should Be Equal As Strings  ${resp.json()['service']['id']}  ${MAX_sid}
        Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}  ${cid}           
        Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${cid1}  
        Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${MAX_qid}

    
        ${resp}=  Cancel Waitlist  ${cwid1}  ${p_id} 
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep   02s  

JD-TC-Add To Waitlist of User ByConsumer-UH10
	[Documentation]  invalid provider

        ${resp}=  Consumer Login  ${CUSERNAME1}  ${PASSWORD}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${cid}=  get_id  ${CUSERNAME1}
        ${INVALID_id}=  get_acc_id  ${Invalid_CUSER}
        
        ${FUTURE_DAY}=  db.add_timezone_date  ${tz}  5  
        ${msg}=  FakerLibrary.word
        ${resp}=  Add To Waitlist Consumer For User  ${INVALID_id}  ${MAX_qid}  ${FUTURE_DAY}  ${MAX_sid}  ${msg}  ${bool[0]}  ${p1_id}  ${self}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  404
        Should Be Equal As Strings  "${resp.json()}"   "${ACCOUNT_NOT_EXIST}"    
    

JD-TC-Add To Waitlist of User ByConsumer-UH11    
    [Documentation]   Add To Waitlist without login
        ${cid}=  get_id  ${CUSERNAME1}
        ${p_id}=  get_acc_id  ${MUSERNAME29}
        
        ${FUTURE_DAY}=  db.add_timezone_date  ${tz}  5  
        ${msg}=  FakerLibrary.word
        ${resp}=  Add To Waitlist Consumer For User  ${p_id}  ${MAX_qid}  ${FUTURE_DAY}  ${MAX_sid}  ${msg}  ${bool[0]}  ${p1_id}  ${self}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  419
        Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"    


JD-TC-Add To Waitlist of User ByConsumer-UH12
     [Documentation]   Add to waitlist on a non scheduled day

        ${resp}=  Encrypted Provider Login  ${MUSERNAME29}  ${PASSWORD}
        Log   ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200
        ${p_id}=  get_acc_id  ${MUSERNAME29}
       
        ${resp}=  Create Service For User  ${BRANCH_SERVICE1}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  ${EMPTY}  ${totalamt}  ${bool[0]}  ${bool[0]}  ${dep_id}  ${u_id}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${BRANCH_sid}  ${resp.json()}

        ${list}=  Create List  1  2  3  4  5  6
        ${date}=  get_timezone_weekday  ${tz}
        ${list1}=  Create List  ${date}
        ${CUR_DAY}=  db.add_timezone_date  ${tz}  1  
        ${BRANCH_QUEUE}=  FakerLibrary.name
        ${resp}=  Create Queue For User  ${BRANCH_QUEUE}  ${recurringtype[1]}  ${list1}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  10  ${lid}  ${u_id}  ${BRANCH_sid}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${BRANCH_qid}  ${resp.json()}
        
        ${resp}=  Consumer Login  ${CUSERNAME1}  ${PASSWORD}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${cid}=  get_id  ${CUSERNAME1}
    
        ${msg}=  FakerLibrary.word
        ${resp}=  Add To Waitlist Consumer For User  ${p_id}  ${BRANCH_qid}  ${CUR_DAY}  ${BRANCH_sid}  ${msg}  ${bool[0]}  ${p1_id}  ${self}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  422
        Should Be Equal As Strings  "${resp.json()}"  "${HOLIDAY_NON_WORKING_DAY}"   
    

      
JD-TC-Add To Waitlist of User ByConsumer-UH13   
    [Documentation]   Add to waitlist After Business time

        ${resp}=  Encrypted Provider Login  ${MUSERNAME29}  ${PASSWORD}
        Log   ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200
        ${p_id}=  get_acc_id  ${MUSERNAME29}

        ${resp}=  Get Business Profile
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()['baseLocation']['bSchedule']['timespec'][0]['startDate']}  ${DAY1}
        Should Be Equal As Strings  ${resp.json()['baseLocation']['bSchedule']['timespec'][0]['timeSlots'][0]['sTime']}  ${BsTime30}
        Should Be Equal As Strings  ${resp.json()['baseLocation']['bSchedule']['timespec'][0]['timeSlots'][0]['eTime']}  ${BeTime30}
        
        ${resp}=  Create Service For User  ${BRANCH_SERVICE2}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  ${EMPTY}  ${totalamt}  ${bool[0]}  ${bool[0]}  ${dep_id}  ${u_id}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${BRANCH_sid2}  ${resp.json()}

        ${psTime}=  db.subtract_timezone_time  ${tz}  0  45
        ${peTime}=  db.subtract_timezone_time  ${tz}   0  10
        ${list}=  Create List  1  2  3  4  5  6  7
        ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
        ${BRANCH_QUEUE2}=  FakerLibrary.name
        ${resp}=  Create Queue For User  ${BRANCH_QUEUE2}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${psTime}  ${peTime}  1  10  ${lid}  ${u_id}  ${BRANCH_sid2}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${BRANCH_qid2}  ${resp.json()}
        
        ${resp}=  Consumer Login  ${CUSERNAME1}  ${PASSWORD}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${cid}=  get_id  ${CUSERNAME1}
    
        ${msg}=  FakerLibrary.word
        ${resp}=  Add To Waitlist Consumer For User  ${p_id}  ${BRANCH_qid2}  ${CUR_DAY}  ${BRANCH_sid}  ${msg}  ${bool[0]}  ${p1_id}  ${self}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  422
        Should Be Equal As Strings  "${resp.json()}"  "${WAITLIST_BUS_HOURS_END}" 

    

JD-TC-Add To Waitlist of User ByConsumer-UH14
    [Documentation]  Add consumer to waitlist when service time exceeds queue time.
        ${resp}=  Encrypted Provider Login  ${MUSERNAME29}  ${PASSWORD}
        Log   ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200
        ${p_id}=  get_acc_id  ${MUSERNAME29}
        
        ${resp}=  Create Service For User  ${BRANCH_SERVICE3}  ${description}   ${service_duration[0]}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  ${EMPTY}  ${totalamt}  ${bool[0]}  ${bool[0]}  ${dep_id}  ${u_id}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${BRANCH_sid3}  ${resp.json()}

        ${resp}=  Create Service For User  ${BRANCH_SERVICE4}  ${description}   ${service_duration[0]}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  ${EMPTY}  ${totalamt}  ${bool[0]}  ${bool[0]}  ${dep_id}  ${u_id}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${BRANCH_sid4}  ${resp.json()}

        ${psTime}=  add_timezone_time  ${tz}  0  15  
        ${peTime}=  add_timezone_time  ${tz}  0  20
        ${list}=  Create List  1  2  3  4  5  6  7
        ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
        ${BRANCH_QUEUE3}=  FakerLibrary.name
        ${resp}=  Create Queue For User  ${BRANCH_QUEUE3}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${psTime}  ${peTime}  1  10  ${lid}  ${u_id}  ${BRANCH_sid3}   ${BRANCH_sid4}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${BRANCH_qid3}  ${resp.json()}

        ${resp}=  Consumer Login  ${CUSERNAME1}  ${PASSWORD}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${cid}=  get_id  ${CUSERNAME1}
    
        ${msg}=  FakerLibrary.word

        ${resp}=  Add To Waitlist Consumer For User  ${p_id}  ${BRANCH_qid3}  ${CUR_DAY}  ${BRANCH_sid3}  ${msg}  ${bool[0]}  ${p1_id}  ${self}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        # ${resp}=  Add To Waitlist Consumer For User  ${p_id}  ${BRANCH_qid3}  ${CUR_DAY}  ${BRANCH_sid3}  ${msg}  ${bool[0]}  ${p1_id}  ${cidfor}
        # Log   ${resp.content}
        # Should Be Equal As Strings  ${resp.status_code}  200


        ${resp}=  Add To Waitlist Consumer For User  ${p_id}  ${BRANCH_qid3}  ${CUR_DAY}  ${BRANCH_sid4}  ${msg}  ${bool[0]}  ${p1_id}  ${self}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=  Add To Waitlist Consumer For User  ${p_id}  ${BRANCH_qid3}  ${CUR_DAY}  ${BRANCH_sid4}  ${msg}  ${bool[0]}  ${p1_id}  ${cidfor}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  422 
        Should Be Equal As Strings  "${resp.json()}"  "${SERVICE_TIME_MORE_THAN_BUS_HOURS}"  
    
    
JD-TC-Add To Waitlist of User ByConsumer-UH15
	[Documentation]  Add consumer to waitlist for a service with prepayment and try to change prepayment status from prepaymentPending to arrived.   

        comment  Finding billable account
        
        # ${resp}=   Get File    /ebs/TDD/varfiles/musers.py
        # ${len}=   Split to lines  ${resp}
        # ${length}=  Get Length   ${len}

        # FOR    ${a}   IN RANGE    ${length}
        #         clear_service       ${MUSERNAME${a}}
        #         ${resp}=  Encrypted Provider Login  ${MUSERNAME${a}}  ${PASSWORD}
        #         Should Be Equal As Strings    ${resp.status_code}    200
        #         ${domain}=   Set Variable    ${resp.json()['sector']}
        #         ${subdomain}=    Set Variable      ${resp.json()['subSector']}
        #         ${resp2}=   Get Sub Domain Settings    ${domain}    ${subdomain}
        #         Should Be Equal As Strings    ${resp.status_code}    200
        #         Set Suite Variable  ${check}    ${resp2.json()['serviceBillable']} 
        #         Exit For Loop IF     '${check}' == 'True'
        # END

        # Set Suite Variable  ${a}

        ${resp}=  Encrypted Provider Login  ${MUSERNAME10}  ${PASSWORD}
        Log   ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200

        # ${resp}=  Encrypted Provider Login  ${MUSERNAME${a}}  ${PASSWORD}
        # Log   ${resp.content}
        # Should Be Equal As Strings    ${resp.status_code}    200
        Set Test Variable  ${P_Sector}   ${resp.json()['sector']}

        ${pkg_id}=   get_highest_license_pkg
        Log   ${pkg_id}
        Set Suite Variable     ${pkg_id}    ${pkg_id[0]}

        ${resp3}=  Get Business Profile
        Log  ${resp3.json()}
        Should Be Equal As Strings  ${resp3.status_code}  200
        Set Suite Variable   ${check1}   ${resp3.json()['licensePkgID']}
        Run Keyword If    '${check1}' != '${pkg_id[0]}'   Change License Package  ${pkg_id[0]}

        # ${p_id31}=  get_acc_id  ${MUSERNAME${a}}
        # Set Suite Variable  ${p_id31}
        # clear_Department    ${MUSERNAME${a}}
        # clear_service       ${MUSERNAME${a}}
        # clear_location      ${MUSERNAME${a}}

        ${p_id31}=  get_acc_id  ${MUSERNAME10}
        Set Suite Variable  ${p_id31}
        # clear_Department    ${MUSERNAME10}
        # clear_service       ${MUSERNAME10}
        # clear_location      ${MUSERNAME10}

        ${resp}=  Get Account Payment Settings
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Run Keyword If  ${resp.json()['onlinePayment']}==${bool[0]}   Enable Disable Online Payment   ${toggle[0]}

        ${resp}=  Get Account Payment Settings
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${GST_num}  ${pan_num}=   db.Generate_gst_number   ${Container_id}
        ${resp}=  Update Tax Percentage  ${gstpercentage[3]}  ${GST_num} 
        Log   ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}   200

        ${resp}=  Enable Tax
        Log   ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}   200

        ${resp}=  Get Business Profile
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=  Toggle Department Enable
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
    
        ${dep_name1}=  FakerLibrary.bs
        Set Suite Variable   ${dep_name1}
        ${dep_code1}=   Random Int  min=100   max=999
        Set Suite Variable   ${dep_code1}
        ${dep_desc1}=   FakerLibrary.word  
        Set Suite Variable    ${dep_desc1}
        ${resp}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1}
        Should Be Equal As Strings    ${resp.status_code}    200
        Set Suite Variable  ${dep_id}  ${resp.json()}
    
        ${number}=  Random Int  min=1000  max=2000
        ${PUSERNAME_U1}=  Evaluate  ${PUSERNAME}+${number}
        clear_users  ${PUSERNAME_U1}
        Set Suite Variable  ${PUSERNAME_U1}
        ${firstname}=  FakerLibrary.name
        Set Suite Variable  ${firstname}
        ${lastname}=  FakerLibrary.last_name
        Set Suite Variable  ${lastname}
        ${address}=  get_address
        Set Suite Variable  ${address}
        ${dob}=  FakerLibrary.Date
        Set Suite Variable  ${dob}
        ${location}=  FakerLibrary.city
        Set Suite Variable  ${location}
        ${state}=  FakerLibrary.state
        Set Suite Variable  ${state}
        ${resp}=  Get User
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${iscorp_subdomains}=  get_iscorp_subdomains  1
        Log  ${iscorp_subdomains}
        ${length}=  Get Length  ${iscorp_subdomains}
        FOR  ${i}  IN RANGE  ${length}
                Set Test Variable  ${domains}  ${iscorp_subdomains[${i}]['domain']}
                Set Test Variable  ${sub_domains}   ${iscorp_subdomains[${i}]['subdomains']}
                Set Suite Variable  ${sub_domain_id}   ${iscorp_subdomains[${i}]['subdomainId']}
                Exit For Loop IF  '${iscorp_subdomains[${i}]['subdomains']}' == '${P_Sector}'
        END
 

    
        # ${resp}=  Create User  ${firstname}  ${lastname}  ${address}  ${PUSERNAME_U1}  ${dob}    ${Genderlist[0]}  ${userType[0]}  ${P_Email}${PUSERNAME_U1}.${test_mail}  ${location}  ${state}  ${dep_id}  ${sub_domain_id}
        # Log   ${resp.content}
        # Should Be Equal As Strings  ${resp.status_code}  200
        ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U1}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[0]}  ${PUSERNAME_U1}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${countryCodes[1]}  ${PUSERNAME_U1}  ${countryCodes[1]}  ${PUSERNAME_U1} 
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${u_id}  ${resp.json()}
        
        ${resp}=  Get User
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        # Set Suite Variable   ${p1_id}   ${resp.json()[0]['id']}
        # Set Suite Variable   ${p2_id}   ${resp.json()[1]['id']}
        ${len}=  Get Length  ${resp.json()}
        Should Be Equal As Integers  ${len}  2
        FOR  ${i}  IN RANGE   ${len}
                IF  '${resp.json()[${i}]['id']}' == '${u_id}' 
                        Set Suite Variable   ${p1_id}   ${resp.json()[${i}]['id']}
                # ELSE IF  '${resp.json()[${i}]['id']}' == '${u_id}'
                #         Set Suite Variable   ${p1_id}   ${resp.json()[${i}]['id']}
                ELSE IF  '${resp.json()[${i}]['id']}' not in ['${u_id}']
                        Set Suite Variable   ${p2_id}   ${resp.json()[${i}]['id']}
                END
        END

        ${DAY1}=  db.get_date_by_timezone  ${tz}
        Set Suite Variable  ${DAY1}
        ${DAY2}=  db.add_timezone_date  ${tz}  10        
        Set Suite Variable  ${DAY2}
        ${list}=  Create List  1  2  3  4  5  6  7

        Set Suite Variable  ${list}
      # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
        Set Suite Variable   ${sTime1}
        ${eTime1}=  add_timezone_time  ${tz}  2  00  
        Set Suite Variable   ${eTime1}
        ${lid}=  Create Sample Location
        Set Suite Variable  ${lid}
        ${description}=  FakerLibrary.sentence
        ${dur}=  FakerLibrary.Random Int  min=10  max=20
        ${amt}=  FakerLibrary.Random Int  min=200  max=500
        ${min_pre1}=  FakerLibrary.Random Int  min=200  max=${amt}
        ${totalamt}=  Convert To Number  ${amt}  1
        ${balamount}=  Evaluate  ${totalamt}-${min_pre1}
        ${pre_float2}=  twodigitfloat  ${min_pre1}
        ${pre_float1}=  Convert To Number  ${min_pre1}  1

        ${resp}=  Create Service For User  ${SERVICE1}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  ${min_pre1}  ${totalamt}  ${bool[1]}  ${bool[0]}  ${dep_id}  ${u_id}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${s_id15}  ${resp.json()}


        ${resp}=  Get Service By Id   ${s_id15}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${queue_name}=  FakerLibrary.name
        ${resp}=  Create Queue For User  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${lid}  ${u_id}  ${s_id15}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${que_id31}  ${resp.json()}


        ${resp}=  ProviderLogout
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=  Consumer Login  ${CUSERNAME1}  ${PASSWORD}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        
        ${msg}=  FakerLibrary.word
        ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
        
        ${resp}=  Add To Waitlist Consumer For User  ${p_id31}  ${que_id31}  ${CUR_DAY}  ${s_id15}  ${msg}  ${bool[0]}  ${u_id}  ${self}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Suite Variable  ${cwid15_1}  ${wid[0]} 


        ${resp}=  Get consumer Waitlist By Id  ${cwid15_1}  ${p_id31}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        # Verify Response  ${resp}   waitlistStatus=${wl_status[3]}
        # ${resp}=  Get Bill By consumer  ${cwid15_1}  ${p_id31}
        # Log   ${resp.content}
        # Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=  Encrypted Provider Login  ${MUSERNAME10}  ${PASSWORD}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp}=  Waitlist Action  ${waitlist_actions[3]}  ${cwid15_1}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  422
        Should Be Equal As Strings  "${resp.json()}"  "${PAYMENT_NOT_DONE}"


        ${msg}=  Fakerlibrary.word
        ${resp}=  Waitlist Action Cancel  ${cwid15_1}  ${waitlist_cancl_reasn[2]}   ${msg}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200 



JD-TC-Add To Waitlist of User ByConsumer-UH16
	[Documentation]  the consumer add to waitlist for a service with prepayment  , try to change prepaymentPending to STARTED 
    
        ${resp}=  Consumer Login  ${CUSERNAME1}  ${PASSWORD}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${p_id31}=  get_acc_id  ${MUSERNAME${a}}
        
        ${msg}=  FakerLibrary.word
        ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
        ${resp}=  Add To Waitlist Consumer For User  ${p_id31}  ${que_id31}  ${CUR_DAY}  ${s_id15}  ${msg}  ${bool[0]}  ${p1_id}  0
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Suite Variable  ${cwid}  ${wid[0]} 

        ${resp}=  Encrypted Provider Login  ${MUSERNAME${a}}  ${PASSWORD}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp}=  Waitlist Action   ${waitlist_actions[1]}  ${cwid}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  422
        ${WAITLIST_STATUS_NOT_CHANGEABLE}=  Format String  ${WAITLIST_STATUS_NOT_CHANGEABLE}  ${wl_status[3]}   ${wl_status[2]}
        Should Be Equal As Strings  "${resp.json()}"  "${WAITLIST_STATUS_NOT_CHANGEABLE}"


        ${msg}=  Fakerlibrary.word
        ${resp}=  Waitlist Action Cancel  ${cwid}  ${waitlist_cancl_reasn[2]}   ${msg}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200 



JD-TC-Add To Waitlist of User ByConsumer-16
	[Documentation]  the consumer add to waitlist for a service with prepayment  , try to change prepaymentPending to checkedIn 
        ${resp}=  Consumer Login  ${CUSERNAME2}  ${PASSWORD}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${p_id31}=  get_acc_id  ${MUSERNAME${a}}
        
        ${msg}=  FakerLibrary.word
        ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
        ${resp}=  Add To Waitlist Consumer For User  ${p_id31}  ${que_id31}  ${CUR_DAY}  ${s_id15}  ${msg}  ${bool[0]}  ${p1_id}  0
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Suite Variable  ${cwid}  ${wid[0]} 

        ${resp}=  Encrypted Provider Login  ${MUSERNAME${a}}  ${PASSWORD}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp}=  Waitlist Action   ${waitlist_actions[3]}  ${cwid}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  422
        Should Be Equal As Strings  "${resp.json()}"  "${PAYMENT_NOT_DONE}"

        ${msg}=  Fakerlibrary.word
        ${resp}=  Waitlist Action Cancel  ${cwid}  ${waitlist_cancl_reasn[2]}   ${msg}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200 



JD-TC-Add To Waitlist of User ByConsumer-17
	[Documentation]  checking the waitlistStatus of a consumer 
        ${resp}=  Consumer Login  ${CUSERNAME1}  ${PASSWORD}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${p_id31}=  get_acc_id  ${MUSERNAME${a}}
        
        ${msg}=  FakerLibrary.word
        # ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
        ${DAY1}=  db.add_timezone_date  ${tz}  1  
        ${resp}=  Add To Waitlist Consumer For User  ${p_id31}  ${que_id31}  ${DAY1}  ${s_id15}  ${msg}  ${bool[0]}  ${p1_id}  0
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Suite Variable  ${cwid}  ${wid[0]} 

        ${resp}=  Get consumer Waitlist By Id   ${cwid}  ${p_id31}   
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}   waitlistStatus=${wl_status[3]}

        ${resp}=  Cancel Waitlist  ${cwid}  ${p_id31} 
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep   02s


JD-TC-Add To Waitlist of User ByConsumer-18
	[Documentation]  the consumer add to waitlist for a service with prepayment , try to change prepaymentPending to Cancel 
        ${resp}=  Consumer Login  ${CUSERNAME1}  ${PASSWORD}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${cid}=  get_id  ${CUSERNAME1}
        ${p_id31}=  get_acc_id  ${MUSERNAME${a}}
        
        ${msg}=  FakerLibrary.word
        ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
        ${resp}=  Add To Waitlist Consumer For User  ${p_id31}  ${que_id31}  ${CUR_DAY}  ${s_id15}  ${msg}  ${bool[0]}  ${p1_id}  ${self}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Suite Variable  ${cwid}  ${wid[0]}

        ${resp}=  Encrypted Provider Login  ${MUSERNAME${a}}  ${PASSWORD}
        Log   ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200

        ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME1}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${cid4}  ${resp.json()[0]['id']}

        ${resp}=  Consumer Login  ${CUSERNAME1}  ${PASSWORD}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=  Get consumer Waitlist By Id   ${cwid}  ${p_id31}   
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[3]}  partySize=1  waitlistedBy=CONSUMER
        Should Be Equal As Strings  ${resp.json()['service']['name']}  ${SERVICE1}
        Should Be Equal As Strings  ${resp.json()['service']['id']}  ${s_id15}
        Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}  ${cid}
        Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${cid4}
        Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${que_id31}

        ${resp}=  Encrypted Provider Login  ${MUSERNAME${a}}  ${PASSWORD}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        
        ${msg}=  Fakerlibrary.word
        ${resp}=  Waitlist Action Cancel  ${cwid}  ${waitlist_cancl_reasn[2]}   ${msg}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200 

JD-TC-Add To Waitlist of User ByConsumer-19
    
    [Documentation]  Add to waitlist a consumer and completes prepayment

        ${resp}=  Encrypted Provider Login  ${MUSERNAME28}  ${PASSWORD}
        Log   ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200
        Set Test Variable  ${P_Sector}   ${resp.json()['sector']}
        ${p_id}=  get_acc_id  ${MUSERNAME28}

        clear_Department    ${MUSERNAME28}
        clear_service       ${MUSERNAME28}
        clear_location      ${MUSERNAME28}
    
        ${highest_package}=  get_highest_license_pkg
        Log  ${highest_package}
        Set Suite variable  ${lic2}  ${highest_package[0]}
        ${resp}=   Change License Package  ${highest_package[0]}
        Log   ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}   200

        ${resp}=  Get Account Payment Settings
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Run Keyword If  ${resp.json()['onlinePayment']}==${bool[0]}   Enable Disable Online Payment   ${toggle[0]}

        ${resp}=  Get Account Payment Settings
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${GST_num}  ${pan_num}=   db.Generate_gst_number   ${Container_id}
        ${resp}=  Update Tax Percentage  ${gstpercentage[3]}  ${GST_num} 
        Log   ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}   200

        ${resp}=  Enable Tax
        Log   ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}   200
    
        ${resp}=  Toggle Department Enable
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
    
        ${dep_name1}=  FakerLibrary.bs
        Set Suite Variable   ${dep_name1}
        ${dep_code1}=   Random Int  min=100   max=999
        Set Suite Variable   ${dep_code1}
        ${dep_desc1}=   FakerLibrary.word  
        Set Suite Variable    ${dep_desc1}
        ${resp}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1}
        Should Be Equal As Strings    ${resp.status_code}    200
        Set Suite Variable  ${dep_id}  ${resp.json()}
    
        ${number}=  Random Int  min=1000  max=2000
        ${PUSERNAME_U1}=  Evaluate  ${PUSERNAME}+${number}
        clear_users  ${PUSERNAME_U1}
        Set Suite Variable  ${PUSERNAME_U1}
        ${firstname}=  FakerLibrary.name
        Set Suite Variable  ${firstname}
        ${lastname}=  FakerLibrary.last_name
        Set Suite Variable  ${lastname}
        ${address}=  get_address
        Set Suite Variable  ${address}
        ${dob}=  FakerLibrary.Date
        Set Suite Variable  ${dob}
        ${location}=  FakerLibrary.city
        Set Suite Variable  ${location}
        ${state}=  FakerLibrary.state
        Set Suite Variable  ${state}
        ${resp}=  Get User
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${iscorp_subdomains}=  get_iscorp_subdomains  1
        Log  ${iscorp_subdomains}
        ${length}=  Get Length  ${iscorp_subdomains}
        FOR  ${i}  IN RANGE  ${length}
            Set Test Variable  ${domains}  ${iscorp_subdomains[${i}]['domain']}
            Set Test Variable  ${sub_domains}   ${iscorp_subdomains[${i}]['subdomains']}
            Set Suite Variable  ${sub_domain_id}   ${iscorp_subdomains[${i}]['subdomainId']}
            Exit For Loop IF  '${iscorp_subdomains[${i}]['subdomains']}' == '${P_Sector}'
        END
 

    
        # ${resp}=  Create User  ${firstname}  ${lastname}  ${address}  ${PUSERNAME_U1}  ${dob}    ${Genderlist[0]}  ${userType[0]}  ${P_Email}${PUSERNAME_U1}.${test_mail}  ${location}  ${state}  ${dep_id}  ${sub_domain_id}
        # Log   ${resp.content}
        # Should Be Equal As Strings  ${resp.status_code}  200
        ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U1}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[0]}  ${PUSERNAME_U1}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${countryCodes[1]}  ${PUSERNAME_U2}  ${countryCodes[1]}  ${PUSERNAME_U2} 
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${u_id}  ${resp.json()}
        ${resp}=  Get User
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        # Set Suite Variable   ${p1_id}   ${resp.json()[0]['id']}
        # Set Suite Variable   ${p2_id}   ${resp.json()[1]['id']}
        ${len}=  Get Length  ${resp.json()}
        Should Be Equal As Integers  ${len}  2
        FOR  ${i}  IN RANGE   ${len}
                IF  '${resp.json()[${i}]['mobileNo']}' == '${MUSERNAME28}' 
                Set Test Variable   ${p2_id}   ${resp.json()[${i}]['id']}
                ELSE
                Set Test Variable   ${p1_id}   ${resp.json()[${i}]['id']}
                END
        END
    
        ${DAY1}=  db.get_date_by_timezone  ${tz}
        Set Suite Variable  ${DAY1}
        ${DAY2}=  db.add_timezone_date  ${tz}  10        
        Set Suite Variable  ${DAY2}
        ${list}=  Create List  1  2  3  4  5  6  7

        Set Suite Variable  ${list}
        ${sTime1}=  add_timezone_time  ${tz}  0  15  
        Set Suite Variable   ${sTime1}
        ${eTime1}=  add_timezone_time  ${tz}  2  00  
        Set Suite Variable   ${eTime1}
        ${lid}=  Create Sample Location
        Set Suite Variable  ${lid}
        ${description}=  FakerLibrary.sentence
        ${dur}=  FakerLibrary.Random Int  min=10  max=20
        ${amt}=  FakerLibrary.Random Int  min=200  max=500
        ${min_pre1}=  FakerLibrary.Random Int  min=200  max=${amt}
        ${totalamt}=  Convert To Number  ${amt}  1
        ${balamount}=  Evaluate  ${totalamt}-${min_pre1}
        ${pre_float2}=  twodigitfloat  ${min_pre1}
        ${pre_float1}=  Convert To Number  ${min_pre1}  1

        ${resp}=  Create Service For User  ${SERVICE1}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  ${min_pre1}  ${totalamt}  ${bool[1]}  ${bool[0]}  ${dep_id}  ${u_id}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${s_id15}  ${resp.json()}
        ${queue_name}=  FakerLibrary.name
        ${resp}=  Create Queue For User  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${lid}  ${u_id}  ${s_id15}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${que_id28}  ${resp.json()}

        ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME17}  
        Log  ${resp.content}
        Should Be Equal As Strings      ${resp.status_code}  200
        IF   '${resp.content}' == '${emptylist}'
                ${resp1}=  AddCustomer  ${CUSERNAME17}
                Log  ${resp1.content}
                Should Be Equal As Strings  ${resp1.status_code}  200
                Set Suite Variable  ${cid1}   ${resp1.json()}
        ELSE
                Set Suite Variable  ${cid1}  ${resp.json()[0]['id']}
        END

        ${resp}=  ProviderLogout
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=  Consumer Login  ${CUSERNAME17}  ${PASSWORD}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${Pcid17}  ${resp.json()['id']}
    
        ${msg}=  FakerLibrary.word
        # ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
        ${DAY1}=  db.add_timezone_date  ${tz}  1  
        ${resp}=  Add To Waitlist Consumer For User  ${p_id}  ${que_id28}  ${DAY1}  ${s_id15}  ${msg}  ${bool[0]}  ${p1_id}  0
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Suite Variable  ${cwid}  ${wid[0]} 


        ${resp}=  Get consumer Waitlist By Id  ${cwid}  ${p_id}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  paymentStatus=${paymentStatus[0]}   waitlistStatus=${wl_status[3]}
        
        ${resp}=  Make payment Consumer Mock  ${p_id}  ${min_pre1}  ${purpose[0]}  ${cwid}  ${s_id15}  ${bool[0]}   ${bool[1]}  ${Pcid17}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        #         ${resp}=  Make payment Consumer Mock  ${min_pre1}  ${bool[1]}  ${cwid}  ${p_id}  ${purpose[0]}  ${cid1}
        # Log   ${resp.content}
        # Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable   ${mer}   ${resp.json()['merchantId']}  
        Set Suite Variable   ${payref}   ${resp.json()['paymentRefId']}
        sleep  02s
        ${resp}=  Get Payment Details  account-eq=${p_id}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()[0]['amount']}   ${pre_float1}
        Should Be Equal As Strings  ${resp.json()[0]['accountId']}   ${p_id}
        Should Be Equal As Strings  ${resp.json()[0]['paymentMode']}   ${payment_modes[5]}
        Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}   ${cwid}
        Should Be Equal As Strings  ${resp.json()[0]['paymentRefId']}   ${payref} 
        Should Be Equal As Strings  ${resp.json()[0]['paymentPurpose']}   ${purpose[0]}

        ${resp}=  Get Bill By consumer  ${cwid}  ${p_id}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  uuid=${cwid}  netTotal=${totalamt}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  netRate=${totalamt}  billPaymentStatus=${paymentStatus[1]}  totalAmountPaid=${pre_float1}  amountDue=${balamount}

        ${resp}=  Get consumer Waitlist By Id  ${cwid}  ${p_id}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  paymentStatus=${paymentStatus[1]}     waitlistStatus=${wl_status[0]}


        ${resp}=  Cancel Waitlist  ${cwid}  ${p_id} 
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep   02s
      


JD-TC-Add To Waitlist of User ByConsumer-20
    
        [Documentation]  Add consumer to waitlist for Virtual service and completes prepayment
        
        ${resp}=  Encrypted Provider Login  ${MUSERNAME5}  ${PASSWORD}
        Log   ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200
        Set Test Variable  ${P_Sector}   ${resp.json()['sector']}
        ${p_id32}=  get_acc_id  ${MUSERNAME5}

        clear_Department    ${MUSERNAME5}
        clear_service       ${MUSERNAME5}
        clear_location      ${MUSERNAME5}
    
        ${highest_package}=  get_highest_license_pkg
        Log  ${highest_package}
        Set Suite variable  ${lic2}  ${highest_package[0]}
        ${resp}=   Change License Package  ${highest_package[0]}
        Log   ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}   200

        ${resp}=  Get Account Payment Settings
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Run Keyword If  ${resp.json()['onlinePayment']}==${bool[0]}   Enable Disable Online Payment   ${toggle[0]}

        ${resp}=  Get Account Payment Settings
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${GST_num}  ${pan_num}=   db.Generate_gst_number   ${Container_id}
        ${resp}=  Update Tax Percentage  ${gstpercentage[3]}  ${GST_num} 
        Log   ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}   200

        ${resp}=  Enable Tax
        Log   ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}   200

        ${resp}=  View Waitlist Settings
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200
        IF  ${resp.json()['filterByDept']}==${bool[0]}
                ${resp}=  Toggle Department Enable
                Log  ${resp.content}
                Should Be Equal As Strings  ${resp.status_code}  200

        END

        ${dep_name1}=  FakerLibrary.bs
        Set Suite Variable   ${dep_name1}
        ${dep_code1}=   Random Int  min=100   max=999
        Set Suite Variable   ${dep_code1}
        ${dep_desc1}=   FakerLibrary.word  
        Set Suite Variable    ${dep_desc1}
        ${resp}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1}
        Should Be Equal As Strings    ${resp.status_code}    200
        Set Suite Variable  ${dep_id}  ${resp.json()}
    
        ${number}=  Random Int  min=100  max=200
        ${PUSERNAME_U32}=  Evaluate  ${MUSERNAME5}+${number}
        clear_users  ${PUSERNAME_U32}
        Set Suite Variable  ${PUSERNAME_U32}
        ${firstname}=  FakerLibrary.name
        Set Suite Variable  ${firstname}
        ${lastname}=  FakerLibrary.last_name
        Set Suite Variable  ${lastname}
        ${address}=  get_address
        Set Suite Variable  ${address}
        ${dob}=  FakerLibrary.Date
        Set Suite Variable  ${dob}
        ${location}=  FakerLibrary.city
        Set Suite Variable  ${location}
        ${state}=  FakerLibrary.state
        Set Suite Variable  ${state}
        ${resp}=  Get User
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${iscorp_subdomains}=  get_iscorp_subdomains  1
        Log  ${iscorp_subdomains}
        ${length}=  Get Length  ${iscorp_subdomains}
        FOR  ${i}  IN RANGE  ${length}
                Set Test Variable  ${domains}  ${iscorp_subdomains[${i}]['domain']}
                Set Test Variable  ${sub_domains}   ${iscorp_subdomains[${i}]['subdomains']}
                Set Suite Variable  ${sub_domain_id}   ${iscorp_subdomains[${i}]['subdomainId']}
                Exit For Loop IF  '${iscorp_subdomains[${i}]['subdomains']}' == '${P_Sector}'
        END
 
    
        # ${resp}=  Create User  ${firstname}  ${lastname}  ${address}  ${PUSERNAME_U32}  ${dob}    ${Genderlist[0]}  ${userType[0]}  ${P_Email}${PUSERNAME_U32}.${test_mail}  ${location}  ${state}  ${dep_id}  ${sub_domain_id}
        # Log   ${resp.content}
        # Should Be Equal As Strings  ${resp.status_code}  200
        ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U32}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[0]}  ${PUSERNAME_U32}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${countryCodes[1]}  ${PUSERNAME_U32}  ${countryCodes[1]}  ${PUSERNAME_U32} 
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${u_id32}  ${resp.json()}
        
        ${resp}=  Get User
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        # Set Suite Variable   ${p1_id32}   ${resp.json()[0]['id']}
        # Set Suite Variable   ${p0_id32}   ${resp.json()[1]['id']}
        ${len}=  Get Length  ${resp.json()}
        Should Be Equal As Integers  ${len}  2
        FOR  ${i}  IN RANGE   ${len}
                IF  '${resp.json()[${i}]['mobileNo']}' == '${MUSERNAME5}' 
                Set Test Variable   ${p0_id32}   ${resp.json()[${i}]['id']}
                ELSE
                Set Test Variable   ${p1_id32}   ${resp.json()[${i}]['id']}
                END
        END
    
        # ${resp}=  Enable Disable Virtual Service  Enable
        # Log   ${resp.content}
        # Should Be Equal As Strings  ${resp.status_code}  200

        ${ZOOM_id0}=  Format String  ${ZOOM_url}  ${MUSERNAME5}
        Set Suite Variable   ${ZOOM_id0}

        ${instructions1}=   FakerLibrary.sentence
        ${instructions2}=   FakerLibrary.sentence

        ${VirtualcallingMode1}=   Create Dictionary   callingMode=${CallingModes[0]}   value=${ZOOM_id0}   status=ACTIVE    instructions=${instructions1} 
        ${VirtualcallingMode2}=   Create Dictionary   callingMode=${CallingModes[1]}   value=${MUSERNAME5}   countryCode=${countryCodes[0]}  status=ACTIVE    instructions=${instructions2} 
        ${vcm1}=  Create List  ${VirtualcallingMode1}   ${VirtualcallingMode2}

        ${resp}=  Update Virtual Calling Mode   ${vcm1}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=  Get Virtual Calling Mode
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['callingMode']}     ${CallingModes[0]}
        Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['value']}           ${ZOOM_id0}
        Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['status']}          ACTIVE
        Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['instructions']}    ${instructions1}

        Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['callingMode']}     ${CallingModes[1]}
        Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['value']}           ${MUSERNAME5}
        Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['status']}          ACTIVE
        Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['instructions']}    ${instructions2}

        ${PUSERPH_id0}=  Evaluate  ${MUSERNAME5}+10101
        ${ZOOM_Pid0}=  Format String  ${ZOOM_url}  ${PUSERPH_id0}
        Set Suite Variable   ${ZOOM_Pid0}


        Set Test Variable  ${callingMode1}     ${CallingModes[0]}
        Set Test Variable  ${ModeId1}          ${ZOOM_Pid0}
        Set Test Variable  ${ModeStatus1}      ACTIVE
        ${Description1}=    FakerLibrary.sentence
        ${VirtualcallingMode1}=   Create Dictionary   callingMode=${callingMode1}   value=${ModeId1}   status=${ModeStatus1}   instructions=${Description1}
        ${virtualCallingModes}=  Create List  ${VirtualcallingMode1}
    
        
        ${amt}=   Random Int   min=100   max=500
        ${min_pre}=   Random Int   min=10   max=50
        ${min_pre1}=  Convert To Number  ${min_pre}  1
        ${totalamt}=  Convert To Number  ${amt}  1
        ${balamount}=  Evaluate  ${totalamt}-${min_pre1}
        ${pre_float2}=  twodigitfloat  ${min_pre1}
        ${pre_float1}=  Convert To Number  ${min_pre1}  1
        ${description}=    FakerLibrary.word
        Set Test Variable  ${vstype}  ${vservicetype[1]}
        ${resp}=  Create Virtual Service For User  ${SERVICE4}   ${description}   5   ${status[0]}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${min_pre1}  ${totalamt}  ${bool[1]}   ${bool[0]}   ${vstype}   ${virtualCallingModes}  ${dep_id}  ${u_id32}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200 
        Set Suite Variable  ${VS_id1}  ${resp.json()} 
        ${resp}=   Get Service By Id  ${VS_id1}
        Should Be Equal As Strings  ${resp.status_code}  200
        Log   ${resp.content}
        Verify Response  ${resp}  name=${SERVICE4}  description=${description}  serviceDuration=5   notification=${bool[1]}   notificationType=${notifytype[2]}   minPrePaymentAmount=${min_pre1}  totalAmount=${totalamt}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[1]}  serviceType=virtualService   virtualServiceType=${vstype}
        

        ${DAY1}=  db.get_date_by_timezone  ${tz}
        Set Suite Variable  ${DAY1}
        ${DAY2}=  db.add_timezone_date  ${tz}  10        
        Set Suite Variable  ${DAY2}
        ${list}=  Create List  1  2  3  4  5  6  7

        Set Suite Variable  ${list}
      # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
        Set Suite Variable   ${sTime1}
        ${eTime1}=  add_timezone_time  ${tz}  2  00  
        Set Suite Variable   ${eTime1}
        ${lid}=  Create Sample Location
        Set Suite Variable  ${lid}
        ${description2}=  FakerLibrary.sentence
        ${dur2}=  FakerLibrary.Random Int  min=10  max=20
        ${amt2}=  FakerLibrary.Random Int  min=200  max=500
        ${min2_pre1}=  FakerLibrary.Random Int  min=200  max=${amt2}
        ${totalamt2}=  Convert To Number  ${amt2}  1
        ${balamount2}=  Evaluate  ${totalamt2}-${min2_pre1}
        ${pre2_float2}=  twodigitfloat  ${min2_pre1}
        ${pre2_float1}=  Convert To Number  ${min2_pre1}  1

        ${resp}=  Create Service For User  ${SERVICE3}  ${description}   ${dur2}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  ${min2_pre1}  ${totalamt2}  ${bool[1]}  ${bool[0]}  ${dep_id}  ${u_id32}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${NS_id1}  ${resp.json()}
        ${queue_name}=  FakerLibrary.name
        ${resp}=  Create Queue For User  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${lid}  ${u_id32}  ${VS_id1}  ${NS_id1}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${que_id32}  ${resp.json()}
      

        ${resp}=  ProviderLogout
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=  Consumer Login  ${CUSERNAME17}  ${PASSWORD}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${cid1}=  get_id  ${CUSERNAME17}
        
        ${USERPH1_id}=  Evaluate  ${CUSERNAME17}+10001
        ${ZOOM_Pid1}=  Format String  ${ZOOM_url}  ${USERPH1_id}

        Set Suite Variable  ${ZOOM_id}    ${ZOOM_Pid1}
        Set Suite Variable  ${WHATSAPP_id}   ${USERPH1_id}
        ${virtualService}=  Create Dictionary  ${CallingModes[0]}=${ZOOM_id}
    
        ${msg}=  FakerLibrary.word
        ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
        ${resp}=  Consumer Add To WL With Virtual Service For User  ${p_id32}  ${que_id32}  ${CUR_DAY}  ${VS_id1}  ${msg}  ${bool[0]}  ${virtualService}   ${p1_id32}  0
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200    
        
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Test Variable  ${cwid}  ${wid[0]}

        ${resp}=  Encrypted Provider Login  ${MUSERNAME5}  ${PASSWORD}
        Log   ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200

        ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME17}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${cid}  ${resp.json()[0]['id']}

        ${resp}=  Consumer Login  ${CUSERNAME17}  ${PASSWORD}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp}=  Get consumer Waitlist By Id   ${cwid}  ${p_id32}   
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  date=${CUR_DAY}  paymentStatus=${paymentStatus[0]}   waitlistStatus=${wl_status[3]}   partySize=1   waitlistedBy=CONSUMER
        Should Be Equal As Strings  ${resp.json()['service']['name']}  ${SERVICE4}
        Should Be Equal As Strings  ${resp.json()['service']['id']}  ${VS_id1}
        Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}  ${cid1}
        Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${cid}
        Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${que_id32}
        

        ${resp}=  Get consumer Waitlist By Id  ${cwid}  ${p_id32}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  paymentStatus=${paymentStatus[0]}   waitlistStatus=${wl_status[3]}

        ${resp}=  Make payment Consumer Mock  ${p_id32}  ${min_pre1}  ${purpose[0]}  ${cwid}  ${VS_id1}  ${bool[0]}   ${bool[1]}  ${cid1}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        # ${resp}=  Make payment Consumer Mock  ${min_pre1}  ${bool[1]}  ${cwid}  ${p_id32}  ${purpose[0]}  ${cid1}
        # Log   ${resp.content}
        # Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable   ${mer}   ${resp.json()['merchantId']}  
        Set Suite Variable   ${payref}   ${resp.json()['paymentRefId']}
        sleep  04s
        ${resp}=  Get Payment Details  account-eq=${p_id32}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()[0]['amount']}   ${pre_float1}
        Should Be Equal As Strings  ${resp.json()[0]['accountId']}   ${p_id32}
        Should Be Equal As Strings  ${resp.json()[0]['paymentMode']}   ${payment_modes[5]}
        Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}   ${cwid}
        Should Be Equal As Strings  ${resp.json()[0]['paymentRefId']}   ${payref} 
        Should Be Equal As Strings  ${resp.json()[0]['paymentPurpose']}   ${purpose[0]}

        ${resp}=  Get Bill By consumer  ${cwid}  ${p_id32}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  uuid=${cwid}  netTotal=${totalamt}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  netRate=${totalamt}  billPaymentStatus=${paymentStatus[1]}  totalAmountPaid=${pre_float1}  amountDue=${balamount}

        ${resp}=  Get consumer Waitlist By Id  ${cwid}  ${p_id32}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  paymentStatus=${paymentStatus[1]}     waitlistStatus=${wl_status[0]}

        ${resp}=  Encrypted Provider Login  ${MUSERNAME5}  ${PASSWORD}
        Log   ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200

        ${msg}=  Fakerlibrary.word
        ${resp}=  Waitlist Action Cancel  ${cwid}  ${waitlist_cancl_reasn[2]}   ${msg}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep  05s

        ${resp}=  Get Waitlist By Id  ${cwid} 
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[4]}   paymentStatus=${paymentStatus[3]}   partySize=1   waitlistedBy=CONSUMER 



JD-TC-Add To Waitlist of User ByConsumer-UH17
    [Documentation]  add to waitlist, then cancel the waitlist and try to change cancelled waitlit to CHECKIN
        ${resp}=  Encrypted Provider Login  ${MUSERNAME29}  ${PASSWORD}
        Log   ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200
        ${p_id30}=  get_acc_id  ${MUSERNAME29}

        ${resp}=  Get User
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        # Set Suite Variable   ${p2_id30}   ${resp.json()[0]['id']}
        # Set Suite Variable   ${p1_id30}   ${resp.json()[1]['id']}
        # Set Suite Variable   ${p0_id30}   ${resp.json()[2]['id']}
        ${len}=  Get Length  ${resp.json()}
        Should Be Equal As Integers  ${len}  3
        ${userids}=  Create List
        FOR  ${i}  IN RANGE   ${len}
                Append To List  ${userids}  ${resp.json()[${i}]['id']}
        END
        Log  ${userids}

        Sort List  ${userids}
        Log  ${userids}

        Set Suite Variable   ${p2_id30}   ${userids[2]}
        Set Suite Variable   ${p1_id30}   ${userids[1]}
        Set Suite Variable   ${p0_id30}   ${userids[0]}

        ${resp}=  Consumer Login  ${CUSERNAME4}  ${PASSWORD}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${cid}=  get_id  ${CUSERNAME4}
        
    
        ${msg}=  FakerLibrary.word
        ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
        ${resp}=  Add To Waitlist Consumer For User  ${p_id30}  ${que_id}  ${CUR_DAY}  ${s_id1}  ${msg}  ${bool[0]}  ${p1_id30}  ${self}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Suite Variable  ${cwid1}  ${wid[0]} 


        ${resp}=  Get consumer Waitlist By Id   ${cwid1}  ${p_id30}   
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[0]}  paymentStatus=${paymentStatus[0]}  partySize=1  waitlistedBy=CONSUMER  personsAhead=0
        Should Be Equal As Strings  ${resp.json()['service']['name']}  ${SERVICE1}
        Should Be Equal As Strings  ${resp.json()['service']['id']}  ${s_id1}
        Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}  ${cid}           
        Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${cid3}  
        Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${que_id}

        ${resp}=  Cancel Waitlist  ${cwid1}  ${p_id30}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=  Add To Waitlist Consumer For User  ${p_id30}  ${que_id}  ${CUR_DAY}  ${s_id1}  ${msg}  ${bool[0]}  ${p1_id30}  ${self}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Suite Variable  ${cwid2}  ${wid[0]} 

        ${resp}=  Get consumer Waitlist By Id   ${cwid2}  ${p_id30}   
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[0]}  paymentStatus=${paymentStatus[0]}  partySize=1  waitlistedBy=CONSUMER  personsAhead=0
        Should Be Equal As Strings  ${resp.json()['service']['name']}  ${SERVICE1}
        Should Be Equal As Strings  ${resp.json()['service']['id']}  ${s_id1}
        Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}  ${cid}           
        Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${cid3}  
        Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${que_id}


        ${resp}=  Encrypted Provider Login  ${MUSERNAME29}  ${PASSWORD}
        Log   ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200

        ${resp}=  Waitlist Action  CHECK_IN  ${cwid1}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  422
        Should Be Equal As Strings  "${resp.json()}"   "${WAITLIST_CUSTOMER_ALREADY_IN}"

        ${msg}=  Fakerlibrary.word
        ${resp}=  Waitlist Action Cancel  ${cwid2}  ${waitlist_cancl_reasn[2]}   ${msg}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep   02s


JD-TC-Add To Waitlist of User ByConsumer-UH18
    
    [Documentation]  Add to waitlist a another USER (Another USER_id is used to "Add To Waitlist Consumer For User")
        ${resp}=  Encrypted Provider Login  ${MUSERNAME29}  ${PASSWORD}
        Log   ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200
        ${p_id30}=  get_acc_id  ${MUSERNAME29}

        ${resp}=  Get User
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        # Set Suite Variable   ${p2_id30}   ${resp.json()[0]['id']}
        # Set Suite Variable   ${p1_id30}   ${resp.json()[1]['id']}
        # Set Suite Variable   ${p0_id30}   ${resp.json()[2]['id']}
        ${len}=  Get Length  ${resp.json()}
        Should Be Equal As Integers  ${len}  3
        ${userids}=  Create List
        FOR  ${i}  IN RANGE   ${len}
                Append To List  ${userids}  ${resp.json()[${i}]['id']}
        END
        Log  ${userids}

        Sort List  ${userids}
        Log  ${userids}

        Set Suite Variable   ${p2_id30}   ${userids[2]}
        Set Suite Variable   ${p1_id30}   ${userids[1]}
        Set Suite Variable   ${p0_id30}   ${userids[0]}

        ${resp}=  Consumer Login  ${CUSERNAME1}  ${PASSWORD}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${cid}=  get_id  ${CUSERNAME1}
    
        ${msg}=  FakerLibrary.word
        ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
        ${resp}=  Add To Waitlist Consumer For User  ${p_id30}  ${que_id}  ${CUR_DAY}  ${s_id1}  ${msg}  ${bool[0]}  ${p2_id30}  ${self}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  422
        Should Be Equal As Strings  "${resp.json()}"   "${PROVIDER_QUEUE}"

JD-TC-Add To Waitlist of User ByConsumer-UH19
    [Documentation]  add consumer to future waitlist, then cancell the waitlist and try to change cancelled waitlit to CHECKIN
        
        ${resp}=  Consumer Login  ${CUSERNAME1}  ${PASSWORD}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${cid}=  get_id  ${CUSERNAME1}
        ${p_id30}=  get_acc_id  ${MUSERNAME29}
    
        ${msg}=  FakerLibrary.word
        ${FUTURE_DAY}=  db.add_timezone_date  ${tz}  4  
        ${resp}=  Add To Waitlist Consumer For User  ${p_id30}  ${que_id}  ${FUTURE_DAY}  ${s_id1}  ${msg}  ${bool[0]}  ${p1_id30}  ${self}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Suite Variable  ${cwid1}  ${wid[0]} 

        ${resp}=  Encrypted Provider Login  ${MUSERNAME29}  ${PASSWORD}
        Log   ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200

        ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME1}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${cid1}  ${resp.json()[1]['id']}

        ${resp}=  Consumer Login  ${CUSERNAME1}  ${PASSWORD}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        
        ${resp}=  Get consumer Waitlist By Id   ${cwid1}  ${p_id30}   
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  date=${FUTURE_DAY}  waitlistStatus=${wl_status[0]}  paymentStatus=${paymentStatus[0]}  partySize=1  waitlistedBy=CONSUMER  personsAhead=0
        Should Be Equal As Strings  ${resp.json()['service']['name']}  ${SERVICE1}
        Should Be Equal As Strings  ${resp.json()['service']['id']}  ${s_id1}
        Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}  ${cid}           
        Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${cid1}  
        Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${que_id}


        ${resp}=  Cancel Waitlist  ${cwid1}  ${p_id30}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=  Add To Waitlist Consumer For User  ${p_id30}  ${que_id}  ${FUTURE_DAY}  ${s_id1}  ${msg}  ${bool[0]}  ${p1_id30}  ${self}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Suite Variable  ${cwid2}  ${wid[0]} 

        ${resp}=  Get consumer Waitlist By Id   ${cwid2}  ${p_id30}   
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  date=${FUTURE_DAY}  waitlistStatus=${wl_status[0]}  paymentStatus=${paymentStatus[0]}  partySize=1  waitlistedBy=CONSUMER  personsAhead=0
        Should Be Equal As Strings  ${resp.json()['service']['name']}  ${SERVICE1}
        Should Be Equal As Strings  ${resp.json()['service']['id']}  ${s_id1}
        Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}  ${cid}           
        Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${cid1}  
        Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${que_id}


        ${resp}=  Encrypted Provider Login  ${MUSERNAME29}  ${PASSWORD}
        Log   ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200

        ${resp}=  Waitlist Action  CHECK_IN  ${cwid1}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  422
        Should Be Equal As Strings  "${resp.json()}"   "${WAITLIST_CUSTOMER_ALREADY_IN}"

        ${msg}=  Fakerlibrary.word
        ${resp}=  Waitlist Action Cancel  ${cwid2}  ${waitlist_cancl_reasn[2]}   ${msg}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep   02s

JD-TC-Add To Waitlist of User ByConsumer-UH20
    [Documentation]  add to waitlist using Disabled USER_id
        ${resp}=  Encrypted Provider Login  ${MUSERNAME29}  ${PASSWORD}
        Log   ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200
        ${p_id30}=  get_acc_id  ${MUSERNAME29}
    
        ${u_id1}=  Create Sample User
        Set Suite Variable  ${u_id1}

        ${resp}=  EnableDisable User  ${u_id1}  ${toggle[1]}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep   02s

        ${resp}=  Consumer Login  ${CUSERNAME1}  ${PASSWORD}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${cid}=  get_id  ${CUSERNAME1}
        
    
        ${msg}=  FakerLibrary.word
        ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
        ${resp}=  Add To Waitlist Consumer For User  ${p_id30}  ${que_id}  ${CUR_DAY}  ${s_id1}  ${msg}  ${bool[0]}  ${u_id1}  ${self}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  422
        Should Be Equal As Strings  "${resp.json()}"   "${PROVIDER_NOT_ACTIVE}"

        ${resp}=  Encrypted Provider Login  ${MUSERNAME29}  ${PASSWORD}
        Log   ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200
    
JD-TC-Add To Waitlist of User ByConsumer-UH21
	[Documentation]  invalid USER

        ${resp}=  Consumer Login  ${CUSERNAME1}  ${PASSWORD}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${cid}=  get_id  ${CUSERNAME1}
        ${p_id30}=  get_acc_id  ${MUSERNAME29}
        # ${INVALID_id}=  get_acc_id  ${Invalid_CUSER}
        ${INVALID_id}=   Random Int  min=10000   max=20000
        
        ${FUTURE_DAY}=  db.add_timezone_date  ${tz}  5  
        ${msg}=  FakerLibrary.word
        ${resp}=  Add To Waitlist Consumer For User  ${p_id30}  ${que_id}  ${FUTURE_DAY}  ${s_id1}  ${msg}  ${bool[0]}  ${INVALID_id}  ${self}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}   422
        Should Be Equal As Strings  "${resp.json()}"   "${PROVIDER_NOT_EXIST}"    
    
   

    
