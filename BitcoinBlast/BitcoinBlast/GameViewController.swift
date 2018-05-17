//
//  GameViewController.swift
//  BitcoinBlast
//
//  Created by Griffin Beels on 1/27/18.
//  Copyright © 2018 Griffin Beels. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import Gifu

//////////////////////////////////////////////////////////////////////////
struct ObjectMasks {
    static let enemy : UInt32 = 1
    static let projectile : UInt32 = 2
    static let player : UInt32 = 3
}

struct Constants{
    static let ammoImage = "PogChamp.png"
    static let playerImage = "Kappa.png"
    static let enemyImage = "FailFish.png"
    
    static let backgroundImage = "PepeNumbers.gif"
    
    static let initialFireRate = 0.5
    static let initialAmmoSpeed = 1.0
    static let initialProjectileDamageDouble = 1.0
    static let initialProjectileDamageExponent = 0
    
    static let initialEnemySpawnRate = 1.0
    static let initialEnemyHealthDouble = 5.0
    static let initialEnemyHealthExponent = 0
    static let initialEnemySpeed = 5.0
    
    static let initialCurrencyDouble = 0.0
    static let initialCurrencyExponent = 0
    static let initialLevel = 1
}

//////////////////////////////////////////////////////////////////////////

/*
 *
 *
 */
class GameViewController: UIViewController {

    /*
     *
     *
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            let gameScene = StartScene(size: view.frame.size)
            gameScene.scaleMode = .aspectFill
            
            view.presentScene(gameScene)
            view.ignoresSiblingOrder = true
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }

    /*
     *
     *
     */
    override var shouldAutorotate: Bool {
        return false
    }

    /*
     *
     *
     */
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    /*
     *
     *
     */
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    
    /*
     *
     *
     */
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

//////////////////////////////////////////////////////////////////////////

class HyperImageView: UIImageView, GIFAnimatable {
    public lazy var animator: Animator? = {
        return Animator(withDelegate: self)
    }()
    
    override public func display(_ layer: CALayer) {
        updateImageIfNeeded()
    }
}
//////////////////////////////////////////////////////////////////////////
class Economy {
    
    var _currencyDouble : Double = 0.0
    var _currencyExponent : Int = 0
    var _maxLevel : Int = 1
    
    /*
     * Stores the coefficient used for determinining currency;
     * again done for simplicity with calculations.
     */
    var currencyDouble : Double {
        get {
            return _currencyDouble
        }
        set (newVal) {
            _currencyDouble = Double(round(1000*newVal) / 1000)
            UserDefaults.standard.set(_currencyDouble, forKey: "currencyDouble")
        }
    }
    
    /*
     * Stores the exponent used for determining the currency value; this is done
     * so that the processing of addition and such is simply adding ints rather than
     * large numbers!
     */
    var currencyExponent : Int {
        get {
            return _currencyExponent
        }
        set (newVal) {
            _currencyExponent = newVal
            UserDefaults.standard.set(_currencyExponent, forKey: "currencyExponent")
        }
    }
    
    /*
    * Store the maximum level possible for use in determining the health of monsters on
    * start.
    */
 
    var maxLevel : Int {
        get {
            return _maxLevel
        }
        set (newVal) {
            _maxLevel = newVal
            UserDefaults.standard.set(_maxLevel, forKey: "maxLevel")
        }
    }
    
    
    init(){
        //Do something if need be; perhaps save defaults for the player?
        //LOAD THE PLAYERS DEFAULTS
        if ((UserDefaults.standard.object(forKey: "currencyDouble") != nil) && (UserDefaults.standard.object(forKey: "currencyExponent") != nil) &&
            (UserDefaults.standard.object(forKey: "maxLevel") != nil)) {
            currencyDouble = UserDefaults.standard.double(forKey: "currencyDouble")
            currencyExponent = UserDefaults.standard.integer(forKey: "currencyExponent")
            maxLevel = UserDefaults.standard.integer(forKey: "maxLevel")
        }
        else{
            NSLog("FirstTime!")
            UserDefaults.standard.set(Constants.initialCurrencyDouble, forKey: "currencyDouble")
            UserDefaults.standard.set(Constants.initialCurrencyExponent, forKey: "currencyExponent")
            UserDefaults.standard.set(Constants.initialLevel, forKey: "maxLevel")
        }
        UserDefaults.standard.synchronize()
    }
}

//////////////////////////////////////////////////////////////////////////

class ProjectileNode: SKSpriteNode{
    
    init(fileName: String) {
        let texture = SKTexture(imageNamed: fileName)
        super.init(texture: texture, color: UIColor.clear, size: texture.size())
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
//////////////////////////////////////////////////////////////////////////
class EnemyNode: SKSpriteNode{
    
    init(fileName: String) {
        let texture = SKTexture(imageNamed: fileName)
        super.init(texture: texture, color: UIColor.clear, size: texture.size())
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var _enemyHealthDouble : Double = Constants.initialEnemyHealthDouble
    var _enemyHealthExponent : Int = Constants.initialEnemyHealthExponent
    
    var healthDouble : Double {
        get {
            return _enemyHealthDouble
        }
        set (newVal) {
            _enemyHealthDouble = newVal
        }
    }
    
    var healthExponent : Int {
        get {
            return _enemyHealthExponent
        }
        set (newVal) {
            _enemyHealthExponent = newVal
        }
    }
    
    //TODO: add gold values, add other things related to each enemy.
    
}
//////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////
class PlayerNode: SKSpriteNode{
    
    var projectileDamageDouble = Constants.initialProjectileDamageDouble
    var projectileDamageExponent = Constants.initialProjectileDamageExponent
    
    init(fileName: String) {
        let texture = SKTexture(imageNamed: fileName)
        super.init(texture: texture, color: UIColor.clear, size: texture.size())
        
        //LOAD THE PLAYERS DEFAULTS
        if ((UserDefaults.standard.object(forKey: "projectileDouble") != nil) && (UserDefaults.standard.object(forKey: "projectileExponent") != nil)) {
            projectileDouble = UserDefaults.standard.double(forKey: "projectileDouble")
            projectileExponent = UserDefaults.standard.integer(forKey: "projectileExponent")
        }
        else{
            NSLog("FirstTime!")
            UserDefaults.standard.set(Constants.initialProjectileDamageDouble, forKey: "projectileDouble")
            UserDefaults.standard.set(Constants.initialProjectileDamageExponent, forKey: "projectileExponent")
        }
        UserDefaults.standard.synchronize()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var projectileExponent : Int {
        get {
            return projectileDamageExponent
        }
        set (newVal){
            projectileDamageExponent = newVal
            UserDefaults.standard.set(projectileDamageExponent, forKey: "projectileExponent")
        }
    }
    
    var projectileDouble : Double {
        get {
            return projectileDamageDouble
        }
        set (newVal){
            projectileDamageDouble = newVal
            UserDefaults.standard.set(projectileDamageDouble, forKey: "projectileDouble")
        }
    }
    
    //TODO: add player related stuff, I can't think of anything
}
//////////////////////////////////////////////////////////////////////////
/*
 *
 *
 */
class StartScene: SKScene, SKPhysicsContactDelegate {
    
    let defaults = UserDefaults.standard
    
    var background = SKSpriteNode(imageNamed: Constants.backgroundImage)
    var playerImage = PlayerNode(fileName: Constants.playerImage)
    var ammoTimer: Timer!
    var enemyTimer: Timer!
    
    var healthLabel = UILabel()
    var damageLabel = UILabel()
    var monstersKilledLabel = UILabel()
    var currencyLabel = UILabel()
    var levelLabel = UILabel()
    
    var currKilled = 0
    var numKilledEnemies : Int {
        get{
            return currKilled
        }
        set (newVal) {
            currKilled = newVal
            monstersKilledLabel.text = "\(currKilled) / 10"
        }
    }
    
    var economy = Economy()
    
    /*
     *
     *
     */
    override func didMove(to view: SKView) {
        
        physicsWorld.contactDelegate = self
        
        playerImage.position = CGPoint(x: self.size.width/2, y: self.size.height/7)
        playerImage.size = CGSize(width: self.size.width/3, height: self.size.height/5)
        
        playerImage.physicsBody = SKPhysicsBody(rectangleOf: playerImage.size)
        playerImage.physicsBody?.affectedByGravity = false
        playerImage.physicsBody?.categoryBitMask = ObjectMasks.player
        playerImage.physicsBody?.isDynamic = false
        
        run(SKAction.repeatForever(SKAction.sequence([
            SKAction.run(spawnEnemies),
            SKAction.wait(forDuration: Constants.initialEnemySpawnRate)
            ])))
        
        run(SKAction.repeatForever(SKAction.sequence([
            SKAction.run(spawnAmmo),
            SKAction.wait(forDuration: Constants.initialFireRate)
            ])))
        
        background.zPosition = -10
        background.position = CGPoint (x: self.size.width/2 , y: self.size.height/2)
        background.size = self.frame.size
        
        //TODO: Figure out how to make the background a gif
        self.addChild(background)
        self.addChild(playerImage)
        
        labelSetup()
    }
    
    func labelSetup(){
        //create a dummy node
        let enemy = EnemyNode(fileName: Constants.enemyImage)
        determineEnemyHealth(enemy: enemy, level: economy.maxLevel)
        
        //Enemy Health
        healthLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 75, height: 20))
        healthLabel.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        healthLabel.textColor = UIColor.white
        self.view?.addSubview(healthLabel)
        healthLabel.text = "\(enemy.healthDouble) 10^\(enemy.healthExponent) "
        
        //Currency
        currencyLabel = UILabel(frame: CGRect(x: 75, y: 0, width: 100, height: 20))
        currencyLabel.backgroundColor = UIColor(red: 0.1, green: 1.0, blue: 0.1, alpha: 1.0)
        currencyLabel.textColor = UIColor.white
        self.view?.addSubview(currencyLabel)
        currencyLabel.text = "\(economy.currencyDouble) 10^\(economy.currencyExponent) "
        
        //level  [for now, monsters killed]
        monstersKilledLabel = UILabel(frame: CGRect(x: 175, y: 0, width: 75, height: 20))
        monstersKilledLabel.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 1.0, alpha: 1.0)
        monstersKilledLabel.textColor = UIColor.white
        self.view?.addSubview(monstersKilledLabel)
         monstersKilledLabel.text = "\(numKilledEnemies) / 10"
        monstersKilledLabel.textAlignment = .center
        
        //Damage Output (alternatively, add stats page).
        damageLabel = UILabel(frame: CGRect(x: 250, y: 0, width: 75, height: 20))
        damageLabel.backgroundColor = UIColor(red: 0.1, green: 0.5, blue: 0.5, alpha: 1.0)
        damageLabel.textColor = UIColor.white
        self.view?.addSubview(damageLabel)
        damageLabel.text = "\(playerImage.projectileDouble) 10^\(playerImage.projectileExponent) "
        
        //Making sure default level appears
        levelLabel = UILabel(frame: CGRect(x: 325, y: 0, width: 50, height: 20))
        levelLabel.backgroundColor = UIColor(red: 0.1, green: 0.3, blue: 0.5, alpha: 1.0)
        levelLabel.textColor = UIColor.white
        self.view?.addSubview(levelLabel)
        levelLabel.text = "\(economy.maxLevel)"
        levelLabel.textAlignment = .center
        
        let button = UIButton(frame: CGRect(x: 0, y: 600, width: 100, height: 50))
        button.backgroundColor = .green
        button.setTitle("DMG UP", for: .normal)
        button.addTarget(self, action: #selector(buttonActionOne), for: .touchUpInside)
        self.view?.addSubview(button)
    }
    
    @objc func buttonActionOne(sender: UIButton!){
        //create a dummy node
        let enemy = EnemyNode(fileName: Constants.enemyImage)
        determineEnemyHealth(enemy: enemy, level: economy.maxLevel)
        
        if (economy.currencyDouble >= enemy.healthDouble && economy.currencyExponent >= enemy.healthExponent){
        playerImage.projectileDamageDouble += Double(5 + enemy.healthExponent) * pow(Double(1.5), Double(enemy.healthExponent))
        
        while (playerImage.projectileDamageDouble >= 10.0){
            playerImage.projectileDamageDouble /= 10.0
            playerImage.projectileDamageExponent += 1
        }
        
        economy.currencyDouble -= enemy.healthDouble
        if (economy.currencyDouble < 0.0){
            economy.currencyDouble = 1 - (-1.0 * economy.currencyDouble)
        }
            
        damageLabel.text = "\(playerImage.projectileDamageDouble) 10^\(playerImage.projectileDamageExponent) "
        
        currencyLabel.text = "\(economy.currencyDouble) 10^\(economy.currencyExponent) "
        checkLevelUnlock()
        }
    }
    
    func determineEnemyHealth(enemy: EnemyNode, level: Int) {
        //insert formula here for determining health given a level
        let temp : Double = ceil(10 * (Double(level - 1) + pow(Double(1.55), Double(level - 1))))
        
        //determine the number to left and right of temp; fractional part does not get used it's ok
        let (wholePart, _) = modf(temp)
        
        //determine the exponent by converting to a string
        let stringTemp : String = String(format: "%.0f", wholePart)
        enemy.healthExponent = Int(stringTemp.count - 2)
   
        //determine the double by dividing temp by 10^enemy._enemyHealthExponent
        let meme : Double = temp / pow(Double(10.000), Double(enemy.healthExponent))
        enemy.healthDouble = Double(round(1000*meme) / 1000) / 10
    }
    
    func determineProjectileDamage(projectile: ProjectileNode, level: Int) {
        //insert formula here for determining health given a level
        
        //if array is of whatever level, then just access the variable instead
        //of determining new value for the damage
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let firstObj : SKPhysicsBody = contact.bodyA
        let secondObj : SKPhysicsBody = contact.bodyB
        
        //Test for two cases where contact is between enemy / projectile
        if ((firstObj.categoryBitMask == ObjectMasks.enemy && secondObj.categoryBitMask == ObjectMasks.projectile)){
            
            dealDamage(enemy: firstObj.node as! EnemyNode, projectile: secondObj.node as! ProjectileNode)
        }
        else if ((firstObj.categoryBitMask == ObjectMasks.projectile &&
            secondObj.categoryBitMask == ObjectMasks.enemy)){
            
            dealDamage(enemy: secondObj.node as! EnemyNode, projectile: firstObj.node as! ProjectileNode)
        }
    }
    
    func dealDamage(enemy: EnemyNode, projectile: ProjectileNode){
        //Case where exponents are different
        if (playerImage.projectileDamageExponent > enemy.healthExponent){
            enemy.healthDouble = 0.000
            enemy.healthExponent = 0
        }
        else if (playerImage.projectileDamageExponent < enemy.healthExponent) {
            let exponentialDifference = enemy.healthExponent - playerImage.projectileDamageExponent
            
            let subtractableVal = playerImage.projectileDamageDouble / Double((10^exponentialDifference))
            
            enemy.healthDouble -= subtractableVal
        }
        //case where exponents are the same
        else {
        enemy.healthDouble -= playerImage.projectileDamageDouble
            //if the subtraction overflows into the negatives
            if (enemy.healthDouble <= 0.000){
                enemy.healthExponent = 0
            }
        }
        
        //if the subtraction warrants an exponent decrementation
        if (enemy.healthDouble < 1.000 && enemy.healthDouble > 0.000){
            //increment health by factor of 10; decrement exponent by 1 until stable
            while (enemy.healthDouble < 1.000 && enemy.healthExponent >= 0){
                enemy.healthDouble *= 10
                enemy.healthExponent -= 1
            }
        }
        
        if (enemy.healthDouble <= 0.000 && enemy.healthExponent <= 0){
            //determine the number to left and right of temp; fractional part does not get used it's ok
            //create a dummy node
            let enemyDummy = EnemyNode(fileName: Constants.enemyImage)
            determineEnemyHealth(enemy: enemyDummy, level: economy.maxLevel)
        // NSLog("\(enemyDummy.healthDouble)")
            let (wholePart, decPart) = modf(enemyDummy.healthDouble / 1.2)
        //NSLog("\(wholePart)")
            //determine the gold by multiplying by 10^healthExponent
            var meme : Double = wholePart * pow(Double(10.000), Double(enemyDummy.healthExponent))
            meme = Double(round(1000*meme) / 1000)
        //NSLog("\(Double(round(1000*meme) / 1000))")
            enemy.removeFromParent()
            
            numKilledEnemies += 1
            
            //now we add gold
            //determine the exponent by converting to a string
            let stringTemp : String = String(format: "%.0f", meme)
            let memeExp = Int(stringTemp.count - 1)
            // CASE WHERE MEME EXPONENT GREATER THAN ECO EXPONENT
            if (memeExp > economy.currencyExponent){
                let exponentialDifference = memeExp - economy.currencyExponent
                
                let addableValue = economy.currencyDouble / Double((10^exponentialDifference))
                
                 economy.currencyExponent = memeExp
                 economy.currencyDouble = wholePart + addableValue
            }
            //CASE WHERE ECO EXPONENT IS GREATER THAN MEME
            else if (economy.currencyExponent > memeExp){
                let exponentialDifference = economy.currencyExponent - memeExp
                
                let addableValue = wholePart / Double(10^(exponentialDifference))
                
                economy.currencyDouble += addableValue
            }
            else{ //must be equiv
                if (wholePart >= 0.0 && wholePart < 1.0){
                    economy.currencyDouble += decPart
                }
                else{
                    economy.currencyDouble += wholePart
                }
            }
            
            if (economy.currencyDouble >= 10.0){
                economy.currencyDouble /= 10.0
                economy.currencyExponent += 1
            }
            currencyLabel.text = "\(economy.currencyDouble) 10^\(economy.currencyExponent) "
            checkLevelUnlock()
        }
        projectile.removeFromParent()
    }
    
    func checkLevelUnlock(){
        //Check to make sure that 10 enemies have been killed, and then upgrade levels
        if (numKilledEnemies >= 10){
            numKilledEnemies = 0
            economy.maxLevel += 1
            levelLabel.text = "\(economy.maxLevel)"
            
            //create a dummy node
            let enemy = EnemyNode(fileName: Constants.enemyImage)
            determineEnemyHealth(enemy: enemy, level: economy.maxLevel)
            healthLabel.text = "\(enemy.healthDouble) 10^\(enemy.healthExponent) "
        }
    }
    
    /*
     *
     *
     */
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    /*
     *
     *
     */
    func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    
    /*
     *
     *
     */
    func spawnAmmo(){
        
        let bullet = ProjectileNode(fileName: Constants.ammoImage)
        
        bullet.zPosition = -5
        bullet.size = CGSize(width: self.size.width / 6, height: self.size.height/10)
        bullet.physicsBody = SKPhysicsBody(rectangleOf: bullet.size)
        bullet.physicsBody?.affectedByGravity = false
        bullet.physicsBody?.categoryBitMask = ObjectMasks.projectile
        bullet.physicsBody?.contactTestBitMask = ObjectMasks.enemy
        bullet.physicsBody?.isDynamic = false
        
        bullet.position = CGPoint(x: playerImage.position.x, y: playerImage.position.y)
        
        let action = SKAction.moveTo(y: self.size.height + bullet.size.height, duration: Constants.initialAmmoSpeed)
        
        let actionMoveDone = SKAction.removeFromParent()
        
        bullet.run(SKAction.sequence([action, actionMoveDone]))
        
        self.addChild(bullet)
    }
    
    /*
     *
     *
     */
    func spawnEnemies(){
        let enemy = EnemyNode(fileName: Constants.enemyImage)
        
        determineEnemyHealth(enemy: enemy, level: economy.maxLevel)
        
        enemy.size = CGSize(width: self.size.width / 5, height: self.size.height/7.5)
        
        let actualX = random(min: enemy.size.width / 2, max: size.width - enemy.size.width/2)
        
        let physicsSize = CGSize(width: enemy.size.width / 2, height: enemy.size.height / 2)
        
        enemy.physicsBody = SKPhysicsBody(rectangleOf: physicsSize)
        enemy.physicsBody?.affectedByGravity = false
        enemy.physicsBody?.categoryBitMask = ObjectMasks.enemy
        enemy.physicsBody?.contactTestBitMask = ObjectMasks.projectile
        enemy.physicsBody?.isDynamic = true
        
        enemy.position = CGPoint(x: actualX, y: self.size.height)
        let actualDuration = random(min: CGFloat(Constants.initialEnemySpeed), max: CGFloat(2*Constants.initialEnemySpeed))
        
        let action = SKAction.moveTo(y: 0 - enemy.size.height, duration: TimeInterval(actualDuration))
        
        let actionMoveDone = SKAction.removeFromParent()
        
        enemy.run(SKAction.sequence([action, actionMoveDone]))
        
        self.addChild(enemy)
    }
    
    /*
     *
     *
     */
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: AnyObject in touches {
            let location = touch.location(in: self)
            playerImage.position.x = location.x
            playerImage.position.y = location.y
        }
    }
    
    /*
     *
     *
     */
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
}

