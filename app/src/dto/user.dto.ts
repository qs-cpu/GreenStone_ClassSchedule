export interface UserDTO {
  id: string
  username: string
  nickname: string | null
  role: 'user' | 'admin'
  createdAt: Date
  updatedAt: Date
}

export interface UserDetailDTO extends UserDTO {
  stats: {
    timetableCount: number
  }
}

export interface UserListDTO {
  users: UserDTO[]
  total: number
  page: number
  pageSize: number
  totalPages: number
}

export interface UserStatsDTO {
  totalUsers: number
  adminUsers: number
  regularUsers: number
  totalTimetables: number
}

export function toUserDTO(user: any): UserDTO {
  return {
    id: user.id,
    username: user.username,
    nickname: user.nickname,
    role: user.role,
    createdAt: user.createdAt,
    updatedAt: user.updatedAt,
  }
}

export function toUserDetailDTO(user: any, timetableCount: number): UserDetailDTO {
  return {
    ...toUserDTO(user),
    stats: {
      timetableCount,
    },
  }
}

export function toUserListDTO(users: any[], total: number, page: number, pageSize: number): UserListDTO {
  return {
    users: users.map(toUserDTO),
    total,
    page,
    pageSize,
    totalPages: Math.ceil(total / pageSize),
  }
}

export function toUserStatsDTO(
  totalUsers: number,
  adminUsers: number,
  totalTimetables: number
): UserStatsDTO {
  return {
    totalUsers,
    adminUsers,
    regularUsers: totalUsers - adminUsers,
    totalTimetables,
  }
}
