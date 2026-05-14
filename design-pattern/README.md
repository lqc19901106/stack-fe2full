# 设计模式资料整理

## 1. 设计模式简介

设计模式是一套被反复验证的解决方案，用于处理软件设计过程中常见问题。它不是代码模板，而是帮助开发者提高代码可维护性、可扩展性、可复用性和系统稳定性的思想。

- **目的**：解决架构设计、对象创建、行为组合和职责划分中的常见问题。
- **核心价值**：提高系统内聚性、减少耦合、明确职责、控制复杂度。
- **使用方式**：根据问题场景选择合适模式，而不是为了模式而模式。

## 2. 设计模式分类

### 2.1 创建型模式

关注对象如何创建，目的是将对象创建过程与业务逻辑解耦。

- **工厂方法（Factory Method）**
  - 适用场景：需要一个统一接口创建多个具体实现，且客户端无需了解具体实现类。
  - 价值：延迟实现类选择、方便扩展新类型。

  ```js
  class Product {
    constructor(name) {
      this.name = name;
    }
    use() {
      return `use ${this.name}`;
    }
  }

  class Creator {
    factoryMethod() {
      throw new Error('factoryMethod must be implemented');
    }
    create() {
      const product = this.factoryMethod();
      return product.use();
    }
  }

  class ConcreteCreatorA extends Creator {
    factoryMethod() {
      return new Product('A');
    }
  }

  class ConcreteCreatorB extends Creator {
    factoryMethod() {
      return new Product('B');
    }
  }

  const resultA = new ConcreteCreatorA().create();
  const resultB = new ConcreteCreatorB().create();
  console.log(resultA, resultB);
  ```

- **抽象工厂（Abstract Factory）**
  - 适用场景：需要创建一组相关或依赖对象，并保持这些对象在同一个族内一致。
  - 价值：保证产品族的一致性、降低产品族间耦合。

  ```js
  class Button {
    render() {}
  }
  class Checkbox {
    render() {}
  }

  class MacButton extends Button {
    render() {
      return 'Render Mac button';
    }
  }

  class WindowsButton extends Button {
    render() {
      return 'Render Windows button';
    }
  }

  class MacCheckbox extends Checkbox {
    render() {
      return 'Render Mac checkbox';
    }
  }

  class WindowsCheckbox extends Checkbox {
    render() {
      return 'Render Windows checkbox';
    }
  }

  class UIFactory {
    createButton() {}
    createCheckbox() {}
  }

  class MacFactory extends UIFactory {
    createButton() {
      return new MacButton();
    }
    createCheckbox() {
      return new MacCheckbox();
    }
  }

  class WindowsFactory extends UIFactory {
    createButton() {
      return new WindowsButton();
    }
    createCheckbox() {
      return new WindowsCheckbox();
    }
  }

  function app(factory) {
    const button = factory.createButton();
    const checkbox = factory.createCheckbox();
    console.log(button.render(), checkbox.render());
  }

  app(new MacFactory());
  app(new WindowsFactory());
  ```

- **单例（Singleton）**
  - 适用场景：全局唯一实例、共享资源、配置中心、连接池管理。
  - 价值：控制实例数量，避免重复创建。
  - 风险：如果实现不当，会导致全局状态、测试困难、线程安全问题。

  ```js
  class ConfigService {
    constructor() {
      if (ConfigService.instance) {
        return ConfigService.instance;
      }
      this.settings = {};
      ConfigService.instance = this;
    }

    set(key, value) {
      this.settings[key] = value;
    }

    get(key) {
      return this.settings[key];
    }
  }

  const config1 = new ConfigService();
  const config2 = new ConfigService();
  config1.set('mode', 'prod');
  console.log(config2.get('mode')); // prod
  ```

- **建造者（Builder）**
  - 适用场景：复杂对象构建、参数众多、构造过程需要分步、同一构建过程可产生不同表示。
  - 价值：使构建逻辑与表示分离、提高可读性。

  ```js
  class UserBuilder {
    constructor() {
      this.user = {};
    }
    setName(name) {
      this.user.name = name;
      return this;
    }
    setAge(age) {
      this.user.age = age;
      return this;
    }
    setRole(role) {
      this.user.role = role;
      return this;
    }
    build() {
      return this.user;
    }
  }

  const user = new UserBuilder()
    .setName('Alice')
    .setAge(30)
    .setRole('admin')
    .build();

  console.log(user);
  ```

- **原型（Prototype）**
  - 适用场景：对象复制代替重新构建、创建开销大、需要动态指定实例类型。
  - 价值：通过克隆快速创建对象。

  ```js
  class Prototype {
    constructor(data) {
      this.data = data;
    }
    clone() {
      return new Prototype({ ...this.data });
    }
  }

  const original = new Prototype({ x: 1, y: 2 });
  const copy = original.clone();
  console.log(copy.data);
  ```

### 2.2 结构型模式

关注类或对象如何组合，以形成更大的结构。

- **适配器（Adapter）**
  - 适用场景：接口不兼容但需要协同工作时。
  - 价值：转换接口，避免修改现有代码。

  ```js
  class OldApi {
    request() {
      return 'old response';
    }
  }

  class Adapter {
    constructor(oldApi) {
      this.oldApi = oldApi;
    }
    fetch() {
      return this.oldApi.request();
    }
  }

  const oldApi = new OldApi();
  const adapter = new Adapter(oldApi);
  console.log(adapter.fetch());
  ```

- **装饰器（Decorator）**
  - 适用场景：需要动态扩展对象功能、避免子类爆炸。
  - 价值：按责任链方式组合功能，增强对象行为。

  ```js
  class Coffee {
    cost() {
      return 5;
    }
  }

  class MilkDecorator {
    constructor(coffee) {
      this.coffee = coffee;
    }
    cost() {
      return this.coffee.cost() + 2;
    }
  }

  const coffee = new Coffee();
  const milkCoffee = new MilkDecorator(coffee);
  console.log(milkCoffee.cost()); // 7
  ```

- **代理（Proxy）**
  - 适用场景：访问控制、延迟加载、缓存代理、远程调用。
  - 价值：在不改变接口的前提下插入额外逻辑。

  ```js
  const service = {
    fetchData() {
      return 'data';
    }
  };

  const proxy = new Proxy(service, {
    get(target, prop, receiver) {
      if (prop === 'fetchData') {
        console.log('proxy: before fetch');
      }
      return Reflect.get(target, prop, receiver);
    }
  });

  console.log(proxy.fetchData());
  ```

- **外观（Facade）**
  - 适用场景：为复杂子系统提供统一简化接口。
  - 价值：降低调用复杂度、隐藏内部实现细节。

  ```js
  class EmailService {
    send(email) {
      return `send email to ${email}`;
    }
  }

  class SmsService {
    send(phone) {
      return `send sms to ${phone}`;
    }
  }

  class NotificationFacade {
    constructor() {
      this.emailService = new EmailService();
      this.smsService = new SmsService();
    }
    notify(email, phone) {
      console.log(this.emailService.send(email));
      console.log(this.smsService.send(phone));
    }
  }

  new NotificationFacade().notify('a@example.com', '123456789');
  ```

- **桥接（Bridge）**
  - 适用场景：需要在抽象和实现之间解耦，避免类爆炸。
  - 价值：分别独立扩展抽象和实现。

  ```js
  class Renderer {
    renderCircle(radius) {}
  }

  class SvgRenderer extends Renderer {
    renderCircle(radius) {
      return `<circle r="${radius}"/>`;
    }
  }

  class CanvasRenderer extends Renderer {
    renderCircle(radius) {
      return `canvas circle ${radius}`;
    }
  }

  class Shape {
    constructor(renderer) {
      this.renderer = renderer;
    }
  }

  class Circle extends Shape {
    constructor(renderer, radius) {
      super(renderer);
      this.radius = radius;
    }
    draw() {
      return this.renderer.renderCircle(this.radius);
    }
  }

  console.log(new Circle(new SvgRenderer(), 10).draw());
  console.log(new Circle(new CanvasRenderer(), 20).draw());
  ```

- **组合（Composite）**
  - 适用场景：树形结构表示“整体-部分”关系，如 UI 组件、文件系统。
  - 价值：统一处理叶子对象和组合对象。

  ```js
  class Component {
    constructor(name) {
      this.name = name;
    }
    add() {}
    remove() {}
    display(indent = 0) {}
  }

  class Leaf extends Component {
    display(indent = 0) {
      console.log(' '.repeat(indent) + this.name);
    }
  }

  class Composite extends Component {
    constructor(name) {
      super(name);
      this.children = [];
    }
    add(child) {
      this.children.push(child);
    }
    display(indent = 0) {
      console.log(' '.repeat(indent) + this.name);
      this.children.forEach(child => child.display(indent + 2));
    }
  }

  const root = new Composite('root');
  const left = new Composite('left');
  left.add(new Leaf('leaf A'));
  root.add(left);
  root.add(new Leaf('leaf B'));
  root.display();
  ```

- **享元（Flyweight）**
  - 适用场景：大量相似对象共享状态、减少内存开销。
  - 价值：将可共享状态提取为外部对象。

  ```js
  class Flyweight {
    constructor(shared) {
      this.shared = shared;
    }
    operation(unique) {
      console.log(`shared=${this.shared}, unique=${unique}`);
    }
  }

  class FlyweightFactory {
    constructor() {
      this.pool = new Map();
    }
    get(shared) {
      if (!this.pool.has(shared)) {
        this.pool.set(shared, new Flyweight(shared));
      }
      return this.pool.get(shared);
    }
  }

  const factory = new FlyweightFactory();
  const fly1 = factory.get('state1');
  const fly2 = factory.get('state1');
  fly1.operation('a');
  fly2.operation('b');
  ```

### 2.3 行为型模式

关注对象之间职责分配和通信方式。

- **策略（Strategy）**
  - 适用场景：一组算法或行为可以互换，且算法独立变化。
  - 价值：通过封装行为减少条件分支。

  ```js
  class PaymentStrategy {
    pay(amount) {}
  }

  class AlipayStrategy extends PaymentStrategy {
    pay(amount) {
      return `Pay ${amount} with Alipay`;
    }
  }

  class WechatStrategy extends PaymentStrategy {
    pay(amount) {
      return `Pay ${amount} with WeChat`;
    }
  }

  class Order {
    constructor(strategy) {
      this.strategy = strategy;
    }
    checkout(amount) {
      return this.strategy.pay(amount);
    }
  }

  console.log(new Order(new AlipayStrategy()).checkout(100));
  console.log(new Order(new WechatStrategy()).checkout(200));
  ```

- **模板方法（Template Method）**
  - 适用场景：多个子类有共同流程，但部分步骤各不相同。
  - 价值：将固定流程抽象到父类，子类覆盖可变步骤。

  ```js
  class DataProcessor {
    process() {
      this.read();
      this.transform();
      this.save();
    }
    read() {
      throw new Error('read must be implemented');
    }
    transform() {}
    save() {
      throw new Error('save must be implemented');
    }
  }

  class CsvProcessor extends DataProcessor {
    read() {
      console.log('read csv');
    }
    transform() {
      console.log('transform csv');
    }
    save() {
      console.log('save csv');
    }
  }

  new CsvProcessor().process();
  ```

- **观察者（Observer）**
  - 适用场景：一对多依赖、状态变化通知、事件订阅发布。
  - 价值：解耦发布者和订阅者。

  ```js
  class EventEmitter {
    constructor() {
      this.listeners = new Map();
    }
    on(event, fn) {
      const handlers = this.listeners.get(event) || [];
      handlers.push(fn);
      this.listeners.set(event, handlers);
    }
    emit(event, data) {
      (this.listeners.get(event) || []).forEach(fn => fn(data));
    }
  }

  const emitter = new EventEmitter();
  emitter.on('login', user => console.log('login', user));
  emitter.emit('login', { name: 'Alice' });
  ```

- **命令（Command）**
  - 适用场景：封装请求为对象、延迟执行、撤销/重做、任务队列。
  - 价值：将请求参数化，支持可扩展命令。

  ```js
  class Light {
    on() {
      console.log('light on');
    }
    off() {
      console.log('light off');
    }
  }

  class LightOnCommand {
    constructor(light) {
      this.light = light;
    }
    execute() {
      this.light.on();
    }
  }

  class RemoteControl {
    setCommand(command) {
      this.command = command;
    }
    pressButton() {
      this.command.execute();
    }
  }

  const light = new Light();
  const command = new LightOnCommand(light);
  const remote = new RemoteControl();
  remote.setCommand(command);
  remote.pressButton();
  ```

- **责任链（Chain of Responsibility）**
  - 适用场景：处理请求的职责链、动态组合处理逻辑。
  - 价值：避免过长条件判断，按职责传递。

  ```js
  class Handler {
    setNext(handler) {
      this.next = handler;
      return handler;
    }
    handle(request) {
      if (this.next) {
        return this.next.handle(request);
      }
      return null;
    }
  }

  class AuthHandler extends Handler {
    handle(request) {
      if (!request.user) {
        return 'auth failed';
      }
      return super.handle(request);
    }
  }

  class LogHandler extends Handler {
    handle(request) {
      console.log('log request');
      return super.handle(request);
    }
  }

  const auth = new AuthHandler();
  const logger = new LogHandler();
  auth.setNext(logger);
  console.log(auth.handle({ user: 'Alice' }));
  ```

- **状态（State）**
  - 适用场景：对象行为随状态变化，且状态切换复杂。
  - 价值：将状态封装成独立对象，避免状态判断散落。

  ```js
  class State {
    handle(context) {}
  }

  class OnState extends State {
    handle(context) {
      console.log('turning off');
      context.state = new OffState();
    }
  }

  class OffState extends State {
    handle(context) {
      console.log('turning on');
      context.state = new OnState();
    }
  }

  class Switch {
    constructor() {
      this.state = new OffState();
    }
    press() {
      this.state.handle(this);
    }
  }

  const sw = new Switch();
  sw.press();
  sw.press();
  ```

- **中介者（Mediator）**
  - 适用场景：多个对象之间复杂交互、避免对象间直接耦合。
  - 价值：通过集中调度降低耦合。

  ```js
  class ChatRoom {
    constructor() {
      this.users = [];
    }
    register(user) {
      this.users.push(user);
      user.chatRoom = this;
    }
    send(message, from) {
      this.users.forEach(user => {
        if (user !== from) {
          user.receive(message, from);
        }
      });
    }
  }

  class User {
    constructor(name) {
      this.name = name;
    }
    send(message) {
      this.chatRoom.send(message, this);
    }
    receive(message, from) {
      console.log(`${from.name} to ${this.name}: ${message}`);
    }
  }

  const room = new ChatRoom();
  const alice = new User('Alice');
  const bob = new User('Bob');
  room.register(alice);
  room.register(bob);
  alice.send('hello');
  ```

- **访问者（Visitor）**
  - 适用场景：需要对对象结构执行多种不同操作。
  - 价值：将操作封装到访问者，避免修改对象结构。

  ```js
  class Element {
    accept(visitor) {}
  }

  class ConcreteElementA extends Element {
    accept(visitor) {
      visitor.visitA(this);
    }
    operationA() {
      return 'A';
    }
  }

  class ConcreteElementB extends Element {
    accept(visitor) {
      visitor.visitB(this);
    }
    operationB() {
      return 'B';
    }
  }

  class Visitor {
    visitA(element) {}
    visitB(element) {}
  }

  class ConcreteVisitor extends Visitor {
    visitA(element) {
      console.log('visit ' + element.operationA());
    }
    visitB(element) {
      console.log('visit ' + element.operationB());
    }
  }

  const elements = [new ConcreteElementA(), new ConcreteElementB()];
  const visitor = new ConcreteVisitor();
  elements.forEach(el => el.accept(visitor));
  ```

- **迭代器（Iterator）**
  - 适用场景：需要顺序访问集合元素，且不暴露内部表示。
  - 价值：统一遍历接口。

  ```js
  class Collection {
    constructor(items = []) {
      this.items = items;
    }
    [Symbol.iterator]() {
      let index = 0;
      const items = this.items;
      return {
        next() {
          if (index < items.length) {
            return { value: items[index++], done: false };
          }
          return { done: true };
        }
      };
    }
  }

  const coll = new Collection([1, 2, 3]);
  for (const item of coll) {
    console.log(item);
  }
  ```

## 3. 设计模式选型原则

- **按需求选型**：先看问题是什么，再选择模式，不要先套模式。
- **复杂度匹配**：简单问题优先简单解法，复杂度高、可复用性强的场景才考虑模式。
- **职责单一**：每个模块/类应只承担一类职责，不要为了模式把职责拆得过碎或混在一起。
- **可维护性优先**：选择模式的核心目标是让代码更易读、可测试、可扩展，而不是“为了模式而设计”。
- **避免过度设计**：如果一个类仅有两个状态、一个方法，就不必引入状态模式、策略模式。
- **降低耦合**：优先使用组合、抽象接口和依赖反转，而不是硬编码具体实现。

## 4. 设计模式与实际场景映射

### 4.1 领域和业务层

- 领域对象、实体、聚合根可以采用**策略模式**或**状态模式**来管理复杂业务规则。
- 领域事件、发布-订阅场景适合 **观察者模式** 或 **事件总线**。
- 复杂对象创建可使用 **建造者模式**，尤其是有大量可选参数时。

### 4.2 应用层与服务层

- 服务适配不同外部系统时可用 **适配器模式** 或 **桥接模式**。
- 统一入口请求处理（如中间件、过滤器）常用 **责任链模式**。
- 任务执行、撤销动作可使用 **命令模式**。
- 缓存代理、延迟加载、远程调用可使用 **代理模式**。

### 4.3 前端与 UI

- 组件组合适合 **组合模式**。
- 动态行为切换可采用 **策略模式**。
- 事件订阅和状态变化可用 **观察者模式**。
- 为复杂子系统提供统一入口可用 **外观模式**。

## 5. 设计模式评估要点

- **是否契合当前业务**：模式是否真正解决了当前问题，或只是增加了结构。
- **是否降低耦合**：是否把具体实现从调用者中剥离，是否减少模块间直接依赖。
- **是否提高可测试性**：是否方便替换实现、模拟依赖、单测单个策略/状态。
- **是否保持职责清晰**：每个类/函数是否只承担单一责任。
- **是否避免重复**：是否通过模式复用了公共行为，还是把逻辑分散成多个重复片段。
- **是否便于扩展**：新增新行为/实现时是否只需要增加新类而非修改已有代码。
- **是否管理了复杂度**：如果模式本身过于复杂，则可能得不偿失。

## 6. 常见反模式与误区

- **过度设计**：把简单函数拆成大量 interface/抽象类，导致代码难读。
- **错误抽象**：把变化点抽象成常量或接口，但设计的抽象与业务事实不一致。
- **神对象**：一个类承担太多职责，导致持有大量状态和逻辑。
- **模式滥用**：仅仅因为熟悉某个模式就想套用，而忽略实际可读性和维护成本。
- **依赖具体类**：没有使用接口或抽象层，调用方依赖实现细节，耦合度高。

## 7. 参考资料

- 《设计模式：可复用面向对象软件的基础》 (Gang of Four)
- 《Head First 设计模式》
- 《重构：改善既有代码的设计》
- 《领域驱动设计》
- 《领域驱动设计精粹》
- 《实现领域驱动设计》
- 《Clean Architecture》

## 8. 使用建议

- 先从领域关系、职责边界、变化点分析需求。
- 确定是否需要抽象接口、策略切换和状态管理。
- 如果系统变化频繁，优先考虑模式带来的可扩展性收益。
- 在代码评审过程中，评估模式是否让结构更清晰而不是更复杂。
- 定期复盘设计模式的实际效果，必要时简化或重构。
