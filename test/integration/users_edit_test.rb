require "test_helper"

class UsersEditTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
  end

  test "unsuccessful edit" do
    log_in_as(@user)
    get edit_user_path(@user)
    assert_template 'users/edit'
    patch user_path(@user), params: { user: { name: "",
                                              email: "foo@invalid",
                                              password:              "foo",
                                              password_confirmation: "bar" } }
    assert_template 'users/edit'
    assert_select "div.alert","The form contains 4 errors."
  end

  test "successful edit" do
    log_in_as(@user)
    get edit_user_path(@user)
    assert_template 'users/edit'
    name  = "Foo Bar"
    email = "foo@bar.com"
    patch user_path(@user), params: { user: { name:  name,
                                              email: email,
                                              password:              "",
                                              password_confirmation: "" } }
    assert_not flash.empty?
    assert_redirected_to @user
    @user.reload
    assert_equal name,  @user.name
    assert_equal email, @user.email
  end

  test "successful edit with friendly forwarding" do
    get edit_user_path(@user)                                                   # @userのユーザー編集ページを取得
    assert_equal session[:forwarding_url], edit_user_url(@user)                 # 渡されたURLに転送されているか確認
    log_in_as(@user)                                                            # @userでログイン
    assert_nil session[:forwarding_url]                                         # forwarding_urlの値がnilならtrue(deleteが効いてる)
    name  = "Foo Bar"                                                           # フォーム欄に値を入力する
    email = "foo@bar.com"                                                       
    patch user_path(@user), params: { user: { name: name,                       # 引数としてわざと失敗する値を持ったuserIDをpatchリクエストで送信（更新）する
                                              email: email,
                                              password:              "",
                                              password_confirmation: "" } }
    assert_not flash.empty?                                                     # エラー文が空じゃなければtrue
    assert_redirected_to @user                                                  # michaelのユーザーidページへ移動できたらtrue
    @user.reload
    assert_equal name,  @user.name                                              # DB内の名前と@userの名前が一致していていたらtrue
    assert_equal email, @user.email                                             # DB内のEmailと@userの名前が一致
  end
end
