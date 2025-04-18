////////////////////////////////////////////////////////////////////////////
//
// Copyright 2020 Realm Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or utilied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
////////////////////////////////////////////////////////////////////////////

#ifndef APP_UTILS_HPP
#define APP_UTILS_HPP

#include <realm/util/optional.hpp>
#include <realm/error_codes.hpp>
#include <realm/status_with.hpp>

#include <map>

namespace realm::app {
struct AppError;
struct Response;

class AppUtils {
public:
    static std::optional<AppError> check_for_errors(const Response& response);
    static Response make_apperror_response(const AppError& error);
    static Response make_clienterror_response(ErrorCodes::Error code, const std::string_view message,
                                              std::optional<int> http_status);
    static const std::pair<const std::string, std::string>*
    find_header(const std::string& key_name, const std::map<std::string, std::string>& search_map);
    static bool is_success_status_code(int status_code);
};

} // namespace realm::app

#endif /* APP_UTILS_HPP */
