(import tester :prefix "" :exit true)
(import "src/joy/validator" :prefix "")

(def account-params
  (params
    (validates [:name :email :password] :required true)
    (validates :password :min-length 8)
    (validates :name :max-length 10)
    (validates :name :matches '(between 3 20 (range "AZ" "az" "09")))
    (validates :email :email true)))

(deftest
  (test "invalid-keys with an empty value and blank? predicate"
    (= '(:a) (freeze (invalid-keys [:a] {:a ""} blank?))))

  (test "invalid-keys with a non-empty value and blank? predicate"
    (= (freeze (invalid-keys [:a] {:a "a"} blank?))
       '()))

  (test "params returns a valid dictionary when all required keys are present and not blank"
    (= (freeze (account-params {:name "name" :email "test@example.com" :password "password"}))
       {:name "name" :email "test@example.com" :password "password"}))

  (test "params raises an error when a dictionary doesn't have all required keys"
    (= (try
         (account-params {:name ""})
         ([err]
          (freeze err)))
       {:name "name is required" :email "email is required" :password "password is required"}))

  (test "params raises an error when min-length isn't met"
    (= (try
         (account-params {:name "name" :email "test@example.com" :password "shorty"})
         ([err]
          (freeze err)))
       {:password "password needs to be more than 8 characters"}))

  (test "params raises an error when max-length isn't met"
    (= (try
         (account-params {:name "this is too long" :email "test@example.com" :password "correct horse battery staple"})
         ([err]
          (freeze err)))
       {:name "name needs to be less than 10 characters"}))

  (test "params raises an error when a peg doesn't match"
    (= (try
         (account-params {:name "na" :email "test@example.com" :password "correct horse battery staple"})
         ([err]
          (freeze err)))
       {:name "name needs to match (between 3 20 (range \"AZ\" \"az\" \"09\"))"}))

  (test "params raises an error with an invalid email"
    (= (try
         (account-params {:name "name" :email "not an email" :password "correct horse battery staple"})
         ([err]
          (freeze err)))
       {:email "email needs to be an email"}))

  (let [account-params (params
                          (validates :name :required true :message "can't be blank"))]
    (test "params handles custom error messages"
      (= (try
           (account-params {:name ""})
           ([err]
            (freeze err)))
         {:name "name can't be blank"}))))