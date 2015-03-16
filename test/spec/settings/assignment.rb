class AnotherObject
  extend Settings::Setting::Macro

  setting :some_setting
  setting :some_other_setting
  setting :setting_not_in_the_data
  attr_reader :some_attribute
end

describe Settings::Setting::Assignment do
  specify "Determines whether the attribute is in the settings registry" do
    another_object = AnotherObject.new

    expect(Settings::Setting::Assignment.setting? another_object, :some_setting).to be
    expect(Settings::Setting::Assignment.setting? another_object, :some_attribute).to_not be
  end

  specify "Determines whether the attribute has a setter method" do
    another_object = AnotherObject.new

    expect(Settings::Setting::Assignment.assignable? another_object, :some_setting).to be
    expect(Settings::Setting::Assignment.assignable? another_object, :some_attribute).to_not be
  end

  specify "Assigns the given value to the corresponding attribute on the receiver" do
    another_object = AnotherObject.new

    Settings::Setting::Assignment.assign_value(another_object, :some_setting, "some value")

    expect(another_object.some_setting == "some value").to be
  end
end
