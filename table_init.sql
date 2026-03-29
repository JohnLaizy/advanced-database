CREATE TABLE membership_type (
    membership_type_id  NUMBER          NOT NULL,
    type_name           VARCHAR2(20)    NOT NULL,
    monthly_fee         NUMBER(5,2)     DEFAULT 0.00 NOT NULL,
    description         VARCHAR2(4000),
    CONSTRAINT pk_membership_type PRIMARY KEY (membership_type_id)
);

CREATE TABLE member (
    member_id           NUMBER          NOT NULL,
    name                VARCHAR2(100)   NOT NULL,
    email               VARCHAR2(150)   NOT NULL,
    contact             VARCHAR2(20),
    password_hash       VARCHAR2(255)   NOT NULL,
    registration_date   DATE            DEFAULT SYSDATE NOT NULL,
    status              VARCHAR2(20)    DEFAULT 'active' NOT NULL,
    membership_type_id  NUMBER,
    CONSTRAINT pk_member            PRIMARY KEY (member_id),
    CONSTRAINT uq_member_email      UNIQUE (email),
    CONSTRAINT chk_member_status    CHECK (status IN ('active', 'suspended', 'deleted')),
    CONSTRAINT fk_member_mtype      FOREIGN KEY (membership_type_id)
        REFERENCES membership_type (membership_type_id)
        ON DELETE SET NULL
);

CREATE TABLE delivery_address (
    delivery_address_id NUMBER          NOT NULL,
    address             VARCHAR2(255)   NOT NULL,
    contact_person      VARCHAR2(100),
    contact_no          VARCHAR2(20),
    member_id           NUMBER          NOT NULL,
    CONSTRAINT pk_delivery_address  PRIMARY KEY (delivery_address_id),
    CONSTRAINT fk_daddr_member      FOREIGN KEY (member_id)
        REFERENCES member (member_id)
        ON DELETE CASCADE
);

CREATE TABLE restaurants (
    restaurant_id       NUMBER          NOT NULL,
    name                VARCHAR2(150)   NOT NULL,
    location            VARCHAR2(255)   NOT NULL,
    contact_num         VARCHAR2(20)    NOT NULL,
    category            VARCHAR2(20)    NOT NULL,
    rating              NUMBER(3,2),
    CONSTRAINT pk_restaurants       PRIMARY KEY (restaurant_id),
    CONSTRAINT chk_rest_category    CHECK (category IN ('Halal', 'Non-Halal'))
);

CREATE TABLE menu (
    menu_id             NUMBER          NOT NULL,
    item_name           VARCHAR2(150)   NOT NULL,
    description         VARCHAR2(4000)  NOT NULL,
    price               NUMBER(10,2)    NOT NULL,
    is_available        NUMBER(1)       DEFAULT 1 NOT NULL,
    type                VARCHAR2(10)    NOT NULL,
    is_budget_meal      NUMBER(1)       DEFAULT 0 NOT NULL,
    is_super_deal       NUMBER(1)       DEFAULT 0 NOT NULL,
    restaurant_id       NUMBER          NOT NULL,
    CONSTRAINT pk_menu              PRIMARY KEY (menu_id),
    CONSTRAINT chk_menu_type        CHECK (type IN ('Food', 'Drink')),
    CONSTRAINT chk_menu_avail       CHECK (is_available IN (0, 1)),
    CONSTRAINT chk_menu_budget      CHECK (is_budget_meal IN (0, 1)),
    CONSTRAINT chk_menu_super       CHECK (is_super_deal IN (0, 1)),
    CONSTRAINT fk_menu_restaurant   FOREIGN KEY (restaurant_id)
        REFERENCES restaurants (restaurant_id)
        ON DELETE CASCADE
);

CREATE TABLE voucher (
    voucher_id          NUMBER          NOT NULL,
    voucher_code        VARCHAR2(50)    NOT NULL,
    voucher_type        VARCHAR2(20)    NOT NULL,
    value               NUMBER(10,2)    NOT NULL,
    minimum_spend       NUMBER(10,2)    DEFAULT 0.00 NOT NULL,
    start_date          DATE            NOT NULL,
    end_date            DATE            NOT NULL,
    membership_required VARCHAR2(10)    DEFAULT 'Both' NOT NULL,
    status              VARCHAR2(10)    DEFAULT 'Active' NOT NULL,
    CONSTRAINT pk_voucher           PRIMARY KEY (voucher_id),
    CONSTRAINT uq_voucher_code      UNIQUE (voucher_code),
    CONSTRAINT chk_voucher_type     CHECK (voucher_type IN ('Discount', 'Free Delivery')),
    CONSTRAINT chk_voucher_memreq   CHECK (membership_required IN ('Normal', 'VIP', 'Both')),
    CONSTRAINT chk_voucher_status   CHECK (status IN ('Active', 'Inactive', 'Expired'))
);

CREATE TABLE orders (
    order_id            NUMBER          NOT NULL,
    amount              NUMBER(10,2)    NOT NULL,
    order_date          DATE            DEFAULT SYSDATE NOT NULL,
    order_status        VARCHAR2(30)    NOT NULL,
    order_type          VARCHAR2(10)    NOT NULL,
    restaurant_id       NUMBER          NOT NULL,
    member_id           NUMBER          NOT NULL,
    CONSTRAINT pk_orders            PRIMARY KEY (order_id),
    CONSTRAINT chk_order_type       CHECK (order_type IN ('Delivery', 'Dine-In')),
    CONSTRAINT fk_orders_restaurant FOREIGN KEY (restaurant_id)
        REFERENCES restaurants (restaurant_id),
    CONSTRAINT fk_orders_member     FOREIGN KEY (member_id)
        REFERENCES member (member_id)
);

CREATE TABLE voucher_redemption (
    redemption_id       NUMBER          NOT NULL,
    redeemed_at         DATE            DEFAULT SYSDATE NOT NULL,
    discount_applied    NUMBER(10,2)    DEFAULT 0.00 NOT NULL,
    status              VARCHAR2(10)    DEFAULT 'Pending' NOT NULL,
    order_id            NUMBER          NOT NULL,
    voucher_id          NUMBER          NOT NULL,
    member_id           NUMBER          NOT NULL,
    CONSTRAINT pk_voucher_redemption PRIMARY KEY (redemption_id),
    CONSTRAINT uq_vr_order           UNIQUE (order_id),
    CONSTRAINT chk_vr_status         CHECK (status IN ('Pending', 'Applied', 'Failed')),
    CONSTRAINT fk_vr_order           FOREIGN KEY (order_id)
        REFERENCES orders (order_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_vr_voucher         FOREIGN KEY (voucher_id)
        REFERENCES voucher (voucher_id),
    CONSTRAINT fk_vr_member          FOREIGN KEY (member_id)
        REFERENCES member (member_id)
);

CREATE TABLE order_details (
    order_detail_id     NUMBER          NOT NULL,
    quantity            NUMBER(10)      DEFAULT 1 NOT NULL,
    subtotal            NUMBER(10,2)    NOT NULL,
    order_id            NUMBER          NOT NULL,
    menu_id             NUMBER          NOT NULL,
    CONSTRAINT pk_order_details     PRIMARY KEY (order_detail_id),
    CONSTRAINT fk_od_order          FOREIGN KEY (order_id)
        REFERENCES orders (order_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_od_menu           FOREIGN KEY (menu_id)
        REFERENCES menu (menu_id)
);

CREATE TABLE delivery_company (
    company_id          NUMBER          NOT NULL,
    company_name        VARCHAR2(150)   NOT NULL,
    contact_no          VARCHAR2(20),
    service_type        VARCHAR2(10)    NOT NULL,
    CONSTRAINT pk_delivery_company  PRIMARY KEY (company_id),
    CONSTRAINT chk_dc_service_type  CHECK (service_type IN ('Standard', 'Express'))
);

CREATE TABLE delivery (
    delivery_id             NUMBER          NOT NULL,
    delivery_status         VARCHAR2(30)    NOT NULL,
    delivery_address_id     NUMBER          NOT NULL,
    order_id                NUMBER          NOT NULL,
    company_id              NUMBER          NOT NULL,
    CONSTRAINT pk_delivery          PRIMARY KEY (delivery_id),
    CONSTRAINT uq_delivery_order    UNIQUE (order_id),
    CONSTRAINT fk_delivery_address  FOREIGN KEY (delivery_address_id)
        REFERENCES delivery_address (delivery_address_id),
    CONSTRAINT fk_delivery_order    FOREIGN KEY (order_id)
        REFERENCES orders (order_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_delivery_company  FOREIGN KEY (company_id)
        REFERENCES delivery_company (company_id)
);

CREATE TABLE payments (
    payment_id          NUMBER          NOT NULL,
    payment_method      VARCHAR2(50)    NOT NULL,
    amount              NUMBER(10,2)    NOT NULL,
    status              VARCHAR2(20)    NOT NULL,
    payment_date        DATE            DEFAULT SYSDATE NOT NULL,
    order_id            NUMBER          NOT NULL,
    CONSTRAINT pk_payments          PRIMARY KEY (payment_id),
    CONSTRAINT fk_payments_order    FOREIGN KEY (order_id)
        REFERENCES orders (order_id)
);

CREATE TABLE feedback (
    feedback_id         NUMBER          NOT NULL,
    feedback_type       VARCHAR2(20)    NOT NULL,
    comments            VARCHAR2(4000),
    status              VARCHAR2(20)    DEFAULT 'Pending' NOT NULL,
    order_id            NUMBER          NOT NULL,
    CONSTRAINT pk_feedback          PRIMARY KEY (feedback_id),
    CONSTRAINT chk_feedback_type    CHECK (feedback_type IN ('Complaint', 'Inquiry')),
    CONSTRAINT chk_feedback_status  CHECK (status IN ('Pending', 'Resolved')),
    CONSTRAINT fk_feedback_order    FOREIGN KEY (order_id)
        REFERENCES orders (order_id)
        ON DELETE CASCADE
);