//
//  ViewController.swift
//  hedwig ver 0.1
//
//  Created by lavaspoon on 25/06/2019.
//  Copyright © 2019 lavaspoon. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import GoogleSignIn

class ViewController: UIViewController, GIDSignInUIDelegate {
    
    @IBOutlet var uiIdInput: UITextField!
    @IBOutlet var uiPasswordInput: UITextField!
    
    var id = String()
    var password = String()
    
    // DB 저장되는 파일 경로
    var databasePath = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //  <firebase database 입력 테스트중 >    //
        //let ref = Database.database().reference() //firebase database 경로 변수
       //ref.child("user/name").setValue("Mike") -업뎃
        //ref.childByAutoId().setValue(["email":"Mike","name":"Eunho","id":"lavaspoon","password":"1234"])
       //ref.child("user").removeValue() -삭제
        //  <firebase database 입력 테스트중 끝 >    //
        
        
        
        
        //  구글로그인 시작 //
        GIDSignIn.sharedInstance().uiDelegate = self
        //  구글로그인 끝//
       
        
        
        //< Local SQLite Database >
        // < DB 설정 : DB를 사용하기 위해 미리 파일을 구성하고 테입르을 삽입하는 과정 > //
        
        let fileMgr = FileManager.default // FileManager의 인스턴스 생성
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) // 복잡한 경로 기억하는 함수, 앱의 Document 경로 찾아서 반환해줌
        let docsDir = dirPath[0]
        databasePath = docsDir.appending("/contacts.db")
        
        if !fileMgr.fileExists(atPath: databasePath) { // 파일 존재 여부 판별, 없으면 생성하고 테이블을 구성하는 쿼리 실행
            let contactDB = FMDatabase(path: databasePath) // FMDatabase 클래스의 인스턴스 생성
            
            if contactDB.open() {
                let sql1 = "CREATE TABLE IF NOT EXISTS MEMBER (EMAIL TEXT NOT NULL, NAME TEXT NOT NULL, ID TEXT NOT NULL PRIMARY KEY, PASSWORD TEXT NOT NULL)"
                // if not exists test : 테이블이 존재하지 않으면
                // 실행할 쿼리를 sql1 상수에 미리 저장하고 executeStatements로 구문을 실행해 실제 DB 테이블 생성
                let sql2 = "INSERT INTO MEMBER VALUES ('hedweek@hedweek.co.kr', '운영자', 'root', '1234')"
                if !contactDB.executeStatements(sql1) {
                    NSLog("SQL 오류 1")
                }
                if !contactDB.executeStatements(sql2) {
                    NSLog("SQL 오류 2")
                }
                contactDB.close()
            } else {
                NSLog("contactDB 열기 실패")
            }
        } else {
            NSLog("contactDB가 존재")
        }
        // < SQLite 설정 종료 > //
        
    }
    
    
    
    // <<로그인 버튼 눌렀을때 시작>> //
    
    @IBAction func loginClicked(_ sender: Any) {
        
        let userId = uiIdInput.text
        let userPassword = uiPasswordInput.text
        
        // ID 조회 시작
        let contactDB = FMDatabase(path: databasePath)
        contactDB.open()
        let selectsql = "SELECT * FROM MEMBER WHERE ID = '\(userId!)'"
        do {
            let result = try contactDB.executeQuery(selectsql, values: [])
            if result.next() {
                id = result.string(forColumn: "ID")!
                password = result.string(forColumn: "PASSWORD")!
            }
        } catch {
            NSLog("ID 조회 DB 오류")
        }
        // ID 조회 종료
        
        //메인메뉴로 가는 객체선언
        let menuScreen = self.storyboard!.instantiateViewController(withIdentifier: "mainView")
        menuScreen.modalTransitionStyle = .coverVertical
        //
        
        if (userId != self.id) || (userPassword != self.password) || (userId != nil) || (userPassword != nil) {
            //alert 변수에 UIAlertController 객체가 할당됨
            let alert = UIAlertController(
                title: "알림창",
                message: "아이디나 비밀번호가 일치하지 않습니다.",
                preferredStyle: .alert
            )
            //alert에서 확인버튼 클릭시
            let okAction = UIAlertAction(title: "OK", style: .default){
                (alert:UIAlertAction!) -> Void in
                
            }
            alert.addAction(okAction)
            present(alert,animated: true, completion: nil)
        } else {
            self.present(menuScreen, animated: true, completion: nil)
        }
    }
    
       // <<로그인 버튼 눌렀을때 끝>> //
    
    
    
    
    
    
    
    
    
    
    //------------------lavaspoon 테스트-------------------//
    
    
    //  <<이메일 로그인 테스트(가입버튼)>>   //
    @IBAction func joinClicked(_ sender: Any) {
        
        let alert1 = UIAlertController(title: "회원가입", message: "이메일 회원가입 완료", preferredStyle: .alert)
        let alert2 = UIAlertController(title: "이메일", message: "비번6자리 이상 입력하세요. 또는 중복입니다.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default, handler: nil)
        alert1.addAction(okAction)
        alert2.addAction(okAction)
        
        Auth.auth().createUser(withEmail: uiIdInput.text!, password: uiPasswordInput.text!
        ) { (user, error) in
            if user !=  nil{
                print("register success")
                self.present(alert1, animated: true, completion: nil)
            }
            else{
                print("register failed")
                self.present(alert2, animated: true, completion: nil)
            }
        }
    }
    //  <<이메일 로그인 테스트(로그인버튼)>>  //
    @IBAction func loginClickedtest(_ sender: Any) {
        //메인메뉴로 가는 객체선언
        let menuScreen = self.storyboard!.instantiateViewController(withIdentifier: "mainView")
        menuScreen.modalTransitionStyle = .coverVertical
        //
        let alert = UIAlertController(title: "로그인", message: "로그인실패", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default, handler: nil)
        alert.addAction(okAction)
        
        Auth.auth().signIn(withEmail: uiIdInput.text!, password: uiPasswordInput.text!) { (user, error) in
            if user != nil{
                self.present(menuScreen, animated: true, completion: nil)
                print("login success")
            }
            else{
                print("login fail")
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    //  <<이메일 로그인 테스트(로그인버튼) 끝>>    //
    
    //  <<구글로그인 시작>>    //
    @IBAction func googleSignIn(_ sender: Any) {
        GIDSignIn.sharedInstance().signIn()
    }
    @IBAction func googleLogout(_ sender: Any) {
        GIDSignIn.sharedInstance().signOut()
        NSLog("로그아웃")
    }
    //  <<구글 로그인 끝>>    //
    
    
    
    
    
    
    
    
    
    
    
}

