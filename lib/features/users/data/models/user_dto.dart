import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:flutter_catalog_app/features/users/domain/entities/user.dart';

part 'user_dto.freezed.dart';
part 'user_dto.g.dart';

@freezed
abstract class AddressDto with _$AddressDto {
  const factory AddressDto({
    required String street,
    required String suite,
    required String city,
    required String zipcode,
  }) = _AddressDto;

  factory AddressDto.fromJson(Map<String, dynamic> json) =>
      _$AddressDtoFromJson(json);
}

@freezed
abstract class CompanyDto with _$CompanyDto {
  const factory CompanyDto({
    required String name,
    required String catchPhrase,
  }) = _CompanyDto;

  factory CompanyDto.fromJson(Map<String, dynamic> json) =>
      _$CompanyDtoFromJson(json);
}

@freezed
abstract class UserDto with _$UserDto {
  const UserDto._();

  const factory UserDto({
    required int id,
    required String name,
    required String username,
    required String email,
    required String phone,
    required String website,
    required AddressDto address,
    required CompanyDto company,
  }) = _UserDto;

  factory UserDto.fromJson(Map<String, dynamic> json) => _$UserDtoFromJson(json);

  User toEntity() => User(
        id: id,
        name: name,
        username: username,
        email: email,
        phone: phone,
        website: website,
        city: address.city,
        company: company.name,
      );
}
