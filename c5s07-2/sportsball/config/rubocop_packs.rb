RuboCop::Packs.configure do |config|
  config.permitted_pack_level_cops = %w(
    Packs/ClassMethodsAsPublicApis
    Packs/RootNamespaceIsPackName
    Packs/TypedPublicApis
    Packs/DocumentedPublicApis
  )
  config.required_pack_level_cops = %w()
end
